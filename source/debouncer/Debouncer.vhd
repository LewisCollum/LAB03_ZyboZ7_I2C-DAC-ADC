library ieee;
use ieee.std_logic_1164.all;

library timer_counter;
library enabler;

entity Debouncer is
  generic(clockCycles: positive);
  port(
    clock: in std_logic;
    reset: in std_logic;
    input: in std_logic;
    output: out std_logic);
end entity;

architecture behavioral of Debouncer is
  type TimerCounter is record
    clock: std_logic;
    reset: std_logic;
    isDone: std_logic;
  end record;

  signal counter: TimerCounter;
  signal isTimerBusy: std_logic;

begin

  process(clock)
    impure function isReadyForNewInput return boolean is
    begin
      return isTimerBusy = '1' and
        counter.isDone = '1' and
        input = '0';
    end function;
    
  begin
    if rising_edge(clock) then
      if reset = '1' or isReadyForNewInput then
        isTimerBusy <= '0';
        counter.reset <= '1';
        output <= '0';

      elsif isTimerBusy = '0' and input = '1' then
        isTimerBusy <= '1';
        counter.reset <= '0';
        output <= '1';
      end if;
    end if;
  end process;

  debounceTimer: entity timer_counter.TimerCounter
    generic map(countMax => clockCycles)
    port map(
      clock => counter.clock,
      reset => counter.reset,
      isDone => counter.isDone);

  timerClockEnabler: entity enabler.Enabler(low)
    port map(
      input => clock,
      enable => isTimerBusy,
      output => counter.clock);
      
      
end architecture;
