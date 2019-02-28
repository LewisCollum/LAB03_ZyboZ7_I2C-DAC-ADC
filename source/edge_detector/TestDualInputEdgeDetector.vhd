library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
use vunit_lib.run_pkg.all;

library testing;
use testing.clock_util;
use testing.pulse_util;

use work.test_config;

entity TestDualInputEdgeDetector is
  generic(runner_cfg: string);
end entity;

architecture test of TestDualInputEdgeDetector is
  constant period: time := 20 ns;
  signal unit: test_config.DualInputEdgeDetector;
begin
  clock_util.generateClock(clock => unit.clock, period => period);

  process
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      --unit.first <= '0';
      --unit.second <= '0';
      wait for period*3/4;
      pulse_util.highPulseForTime(unit.reset, period);      

      if run("test_outputTriggers") then
        unit.first <= '1';
        wait for period;
        unit.second <= '1';
        wait for period*5/4 + period/2;                

        assert unit.output = '1';
        wait for period;
        assert unit.output = '0';
                
      end if;
    end loop;
    
    test_runner_cleanup(runner);
  end process;

  unitDualInputEdgeDetector: entity work.DualInputEdgeDetector
    port map(
      clock => unit.clock,
      reset => unit.reset,
      first => unit.first,
      second => unit.second,
      output => unit.output);

end architecture;
