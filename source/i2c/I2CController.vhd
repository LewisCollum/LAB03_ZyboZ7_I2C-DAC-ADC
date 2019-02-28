use work.i2c_pkg;

library ieee;
use ieee.std_logic_1164.all;

entity I2CController is
  port(
    clock: in std_logic;
    reset: in std_logic;
    control: in i2c_pkg.Control;
    data: inout i2c_pkg.Byte;
    slave: inout i2c_pkg.Slave;
    interrupt: out i2c_pkg.Interrupt);
end entity;

architecture behavioral of I2CController is
  signal resetHandler: i2c_pkg.ResetHandler;
  signal enableHandler: i2c_pkg.EnableHandler;
  signal stateController: i2c_pkg.StateController;
  signal internalInterrupt: i2c_pkg.InternalInterrupt;
  signal internalControl: i2c_pkg.Control;

  impure function hasAddressChanged return std_logic is
  begin
    for i in i2c_pkg.SlaveAddress'range loop
      if internalControl.slaveAddress(i) /= control.slaveAddress(i) then
        return '0';
      end if;
    end loop;
    return '1';
  end function;

begin
  internalControl.enable <= enableHandler.enableHandled;
  internalControl.slaveAddress <= control.slaveAddress;
  internalControl.dataDirection <= control.dataDirection;

  internalInterrupt.isBitCounterDone <= '0'; -----------------
  internalInterrupt.hasAddressChanged <= hasAddressChanged;
  internalInterrupt.isStartBitDone <= '0'; ------------------
  internalInterrupt.isBusy <= '0'; ------------------------'

  interrupt.isBusy <= internalInterrupt.isBusy;

  createResetHandler: entity work.ResetHandler
    port map(
      clock => resetHandler.clock,
      resetUnhandled => resetHandler.resetUnhandled,
      readyToReset => resetHandler.readyToReset,
      resetHandled => resetHandler.resetHandled);

  resetHandler.clock <= clock;
  resetHandler.resetUnhandled <= reset;
  resetHandler.readyToReset <= not internalInterrupt.isBusy;
  
  
  createEnableHandler: entity work.EnableHandler
    port map(
      clock => enableHandler.clock,
      resetStart => enableHandler.resetStart,
      resetFinish => enableHandler.resetFinish,
      enableUnhandled => enableHandler.enableUnhandled,
      enableHandled => enableHandler.enableHandled);

  enableHandler.clock <= clock;
  enableHandler.resetStart <= reset;
  enableHandler.resetFinish <= resetHandler.resetHandled;
  enableHandler.enableUnhandled <= control.enable;

  
  createStateController: entity work.StateController
    port map(
      stateController.clock,
      stateController.reset,
      stateController.control,
      stateController.interrupt,
      stateController.state);

  stateController.clock <= clock;
  stateController.reset <= resetHandler.resetHandled;
  stateController.control <= internalControl;
  stateController.interrupt <= internalInterrupt;
  
end architecture;
