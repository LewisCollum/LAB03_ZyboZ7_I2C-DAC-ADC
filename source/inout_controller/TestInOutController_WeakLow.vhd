use work.test_config;
use work.inout_pkg;

library vunit_lib;
use vunit_lib.run_pkg.all;

library ieee;
use ieee.std_logic_1164.all;

entity TestInOutController_WeakLow is
  generic(runner_cfg: string);
end entity;

architecture test of TestInOutController_WeakLow is
  constant period: time := 20 ns;

  signal unit: test_config.InOutController;
  
begin
  process
    procedure disconnectDevicesFromIO is
    begin
      unit.io <= 'Z';
    end procedure;
    
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      disconnectDevicesFromIO;
      unit.sendable <= '0';
      unit.mode <= inout_pkg.setMode(inout_pkg.removed);
      wait for period;

      if run("test_ioToFetchable") then
        unit.mode <= inout_pkg.setMode(inout_pkg.fetch);
        unit.io <= '1';
        wait for period;
        
        assert unit.fetchable = '1';

      elsif run("test_sendableToIO") then
        unit.mode <= inout_pkg.setMode(inout_pkg.send);
        unit.sendable <= '1';
        wait for period;

        assert unit.io = '1';

      elsif run("test_controllerRemoved_ioWeakLow") then

        assert unit.io = 'L';

      elsif run("test_controllerRemovedButIODriven_fetchableIsWeakLow") then
        unit.io <= '1';
        wait for period;

        assert unit.fetchable <= 'L';

      elsif run("test_controllerRemovedButIODriven_ioIsDefined") then
        unit.io <= '1';
        wait for period;
        
        assert unit.io = '1';
        
      end if;
    end loop;
    
    test_runner_cleanup(runner);
  end process;

  setUnit: entity work.InOutController(weak_low)
    port map(
      mode => unit.mode,
      sendable => unit.sendable,
      fetchable => unit.fetchable,
      io => unit.io);

end architecture;
