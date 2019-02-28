library ieee, vunit_lib, testing;
use ieee.std_logic_1164.all;
use vunit_lib.run_pkg.all;
use work.i2c_pkg;
use testing.clock_util;
use testing.pulse_util;

entity TestEnableHandler is
  generic(runner_cfg: string);
end entity;

architecture test of TestEnableHandler is
  constant period: time := 20 ns;
  signal clock: std_logic := '0';
  signal unit: i2c_pkg.EnableHandler;
begin
  process
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
      unit.resetStart <= '0';
      unit.resetFinish <= '0';
      unit.enableUnhandled <= '0';
      wait for period*2;
      
      if run("waveform") then
        unit.enableUnhandled <= '1';
        pulse_util.highPulseForTime(unit.resetStart, period);
        wait for period*5;
        pulse_util.highPulseForTime(unit.resetFinish, period);
        wait for period*5;
      --TODO add assert tests
      end if;
    end loop;
    
    test_runner_cleanup(runner);
  end process;

  unitEnableHandler: entity work.EnableHandler
    port map(unit.clock,
             unit.resetStart, unit.resetFinish,
             unit.enableUnhandled, unit.enableHandled);

  unit.clock <= clock;
  clock_util.generateClock(clock, period);
end architecture;
