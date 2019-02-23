library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity TimerCounter is
  generic(countMax: positive);
  port(
    clock: in std_logic;
    reset: in std_logic;
    isDone: out std_logic);
end entity;

architecture behavioral of TimerCounter is
  subtype CounterMemory is integer range 0 to countMax-1;
  signal count: CounterMemory;
  
begin
  process(reset, clock)
  begin
    if reset = '1' then
      count <= 0;
      isDone <= '0';
      
    elsif rising_edge(clock) then
      if count = CounterMemory'high then
        isDone <= '1';
      else
        count <= count + 1;
        isDone <= '0';
      end if;
    end if;
  end process;
end architecture;
