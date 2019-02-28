use work.i2c_pkg;

library ieee;
use ieee.std_logic_1164.all;

entity StateController is
  port(
    clock: in std_logic;
    reset: in std_logic;
    control: in i2c_pkg.Control;
    interrupt: in i2c_pkg.InternalInterrupt;
    state: buffer i2c_pkg.State);
end entity;

architecture behavioral of StateController is
begin
  process(clock) is
    procedure updateStateMachine;
    procedure updateRunStateMachine;
    impure function mustRestartAfterSendAcknowledge return boolean;
    impure function mustRestartAfterGetAcknowledge return boolean;
    procedure setStateRunToSendOrFetch;    
    
    procedure updateStateMachine is
    begin
      case state.system is
        when i2c_pkg.idle =>
          state.system <= i2c_pkg.run when control.enable = '1';
        when i2c_pkg.run =>
          updateRunStateMachine;
        when i2c_pkg.stop =>
          state.system <= i2c_pkg.idle when interrupt.isEndBitDone = '1';
      end case;    
    end procedure;

    procedure updateRunStateMachine is
    begin
      case state.run is
        when i2c_pkg.start =>
          state.run <= i2c_pkg.sendControl when interrupt.isStartBitDone = '1';
        when i2c_pkg.sendControl =>
          state.run <= i2c_pkg.getFirstAcknowledge when interrupt.isBitCounterDone = '1';
        when i2c_pkg.getFirstAcknowledge =>
          setStateRunToSendOrFetch;
          
        when i2c_pkg.send =>
          state.run <= i2c_pkg.getAcknowledge when interrupt.isBitCounterDone = '1';
        when i2c_pkg.getAcknowledge =>
          state.run <= i2c_pkg.start when mustRestartAfterGetAcknowledge;
          state.system <= i2c_pkg.stop when control.enable = '0';
          
        when i2c_pkg.fetch =>
          state.run <= i2c_pkg.sendAcknowledge when interrupt.isBitCounterDone = '1';
        when i2c_pkg.sendAcknowledge =>
          state.run <= i2c_pkg.start when mustRestartAfterSendAcknowledge;
          state.system <= i2c_pkg.stop when control.enable = '0';
      end case;
    end procedure;

    impure function mustRestartAfterSendAcknowledge return boolean is
    begin
      case control.dataDirection is
        when i2c_pkg.sending =>
          return control.enable = '0' or interrupt.hasAddressChanged = '1';
        when i2c_pkg.fetching =>
          return false;
      end case;
      return false;
      -- return control.enable = '0' or
      --   control.dataDirection = i2c_pkg.sending or
      --   interrupt.hasAddressChanged = '1';
    end function;

    impure function mustRestartAfterGetAcknowledge return boolean is
    begin
      case control.dataDirection is
        when i2c_pkg.fetching =>
          return control.enable = '0' or interrupt.hasAddressChanged = '1';
        when i2c_pkg.sending =>
          return false;
      end case;
      return false;
      -- return control.enable = '0' or
      --   control.dataDirection = i2c_pkg.fetching or
      --   interrupt.hasAddressChanged = '1';
    end function;
    
    procedure setStateRunToSendOrFetch is
    begin
      case control.dataDirection is
        when i2c_pkg.sending =>
          state.run <= i2c_pkg.send;
        when i2c_pkg.fetching =>
          state.run <= i2c_pkg.fetch;
      end case;
    end procedure;

  begin
    if rising_edge(clock) then      
      if reset = '1' then
        state.system <= i2c_pkg.idle;
      else
        updateStateMachine;
      end if;
    end if;
  end process;
end architecture;
