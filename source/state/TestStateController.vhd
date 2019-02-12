library ieee;
use ieee.std_logic_1164.all;

library system_bus;
use system_bus.StateBus.StateBus;
use system_bus.InterruptBus.InterruptBus;

library testing;
use testing.ClockUtilities.all;

library vunit_lib;
context vunit_lib.vunit_context;

library board;
use board.Common.zyboz7;

entity Test_StateController is
  generic (runner_cfg : string);
end entity;

architecture test of Test_StateController is
  signal clock: std_logic;
  signal interrupt: InterruptBus;
  signal state: StateBus;
begin
  main : process
  begin
    test_runner_setup(runner, runner_cfg);
    while test_suite loop
      if run("test_SystemInitialize") then
        wait for zyboz7.period * 5;
        interrupt.lcd.isBusy <= '0';
        interrupt.i2c.isBusy <= '0';
        wait for zyboz7.period * 3;
        report "done";
      end if;
    end loop;
    test_runner_cleanup(runner);
  end process;

  generateClock(clock, frequency => zyboz7.frequency);
  
  unit: entity work.StateController
    port map(
      clock => clock,
      interrupt => interrupt,
      state => state);
end architecture;
