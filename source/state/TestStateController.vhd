library ieee;
library system_bus;
library testing;
library vunit_lib;
library board;

use ieee.std_logic_1164.all;
use system_bus.StateBus.all;

use system_bus.InterruptBus.InterruptBus;
use testing.clock_util;
use testing.pulse_util.all;
use board.ZyboZ7;
use vunit_lib.run_pkg.all;

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

      if run("test_SystemInitializeToFetch") then
        wait for period * 2;
        assert state.system = fetch;
        
      end if;
    end loop;
    wait for period*2;
    
    test_runner_cleanup(runner);
  end process;

  clock_util.generateClock(clock, period => ZyboZ7.clock.period);
  
  unit: entity work.StateController
    port map(
      clock => clock,
      interrupt => interrupt,
      state => state);
end architecture;
