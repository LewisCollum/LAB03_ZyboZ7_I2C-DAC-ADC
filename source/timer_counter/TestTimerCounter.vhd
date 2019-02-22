library ieee;
library vunit_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use vunit_lib.run_pkg.all;
use work.test_config;

entity TestTimerCounter is
  generic(runner_cfg: string);
end entity;

architecture test of TestTimerCounter is
  constant period: time := 20 ns;
  signal clock: std_logic := '0';
  signal timerCounter: test_config.TimerCounter;
begin
  clock <= not clock after period/2;
  timerCounter.clock <= clock;
  
  process
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      timerCounter.reset <= '1';
      wait for period/2;
      timerCounter.reset <= '0';
      wait for period*(test_config.countMax - 1);

      if run("test_CheckTimerIsDone") then
        assert timerCounter.isDone = '0';
        wait for period;
        assert timerCounter.isDone = '1';

      elsif run("test_IsDoneUntilReset") then
        wait for period*2;
        timerCounter.reset <= '1';
        wait for period;

        assert timerCounter.isDone = '0';
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  unit: entity work.TimerCounter
    generic map(countMax => test_config.countMax)
    port map(
      clock => timerCounter.clock,
      reset => timerCounter.reset,
      isDone => timerCounter.isDone); 
    
end architecture;
