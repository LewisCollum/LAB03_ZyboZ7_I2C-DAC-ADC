library ieee;
library system_bus;
library testing;
library vunit_lib;
library board;

use ieee.std_logic_1164.all;
use system_bus.StateBus.all;

use system_bus.InterruptBus.InterruptBus;
use testing.ClockUtilities.all;
use testing.PulseUtilities.all;
use board.ZyboZ7;
context vunit_lib.vunit_context;

entity Test_StateController is
  generic (runner_cfg : string);
end entity;

architecture test of Test_StateController is
  constant period: time := ZyboZ7.clock.period;
  signal clock: std_logic;
  signal interrupt: InterruptBus;
  signal state: StateBus;
begin

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      interrupt <= (
        button => (others => '0'),
        lcd => (others => '0'),
        i2c => (others => '0'));

      if run("test_SystemInitializeToPause") then
        assert state.system = initialize;    
        wait for period * 2;
        assert state.system = pause;
        wait for period / 2;
        highPulseForTime(interrupt.button.pause, period);
        assert state.system = pause;
        wait for period * 5;
        
      elsif run("test_PauseToReset") then
        wait for period;
        --state.system <= pause;

        wait for period * 5/2;
        highPulseForTime(interrupt.button.reset, period*2);
        wait until rising_edge(clock);
        assert state.system = initialize;
      
      end if;
    end loop;
    wait for period*2;
    
    test_runner_cleanup(runner);
  end process;

  generateClock(clock, frequency => ZyboZ7.clock.frequency);
  
  unit: entity work.StateController
    port map(
      clock => clock,
      interrupt => interrupt,
      state => state);
end architecture;
