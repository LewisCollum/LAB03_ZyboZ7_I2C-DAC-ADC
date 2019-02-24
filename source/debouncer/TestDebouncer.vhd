use work.test_config;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
use vunit_lib.run_pkg.all;

library testing;
use testing.pulse_util;
use testing.clock_util;

entity TestDebouncer is
  generic(runner_cfg: string);
end entity;

architecture test of TestDebouncer is
  constant period: time := 20 ns;
  signal debouncer: test_config.Debouncer;
  
begin
  clock_util.generateClock(clock => debouncer.clock, period => period);
  
  process
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      wait for period*3/4;
      pulse_util.highPulseForTime(debouncer.reset, period);

      if run("test_MultipleButtonPresses_OnlyTriggersDebouncerOnce") then
        pulse_util.highPulseForTime(debouncer.input, period);
        wait for period*(test_config.clockCycles - 1);
        pulse_util.highPulseForTime(debouncer.input, period);
        wait for period;

        assert debouncer.output = '0';

      elsif run("test_OutputStaysHighForClockCycles") then
        pulse_util.highPulseForTime(debouncer.input, period);
        wait for period;

        assert debouncer.output = '1';
        wait for period*(test_config.clockCycles - 3);
        assert debouncer.output = '1';

      elsif run("test_holdInputHigh_OutputStaysHigh") then
        debouncer.input <= '1';
        wait for period*(test_config.clockCycles + 1);
        
        assert debouncer.output = '1';

        wait for period*5;
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  unit: entity work.Debouncer
    generic map(clockCycles => test_config.clockCycles)
    port map(
      clock => debouncer.clock,
      reset => debouncer.reset,
      input => debouncer.input,
      output => debouncer.output); 
    
end architecture;
