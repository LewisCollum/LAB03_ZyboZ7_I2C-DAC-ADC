library ieee;
use ieee.std_logic_1164.all;

entity EdgeDetector is
  port(
    clock: in std_logic;
    reset: in std_logic;
    input: in std_logic;
    output: out std_logic);
end entity;

architecture rising of EdgeDetector is
  signal isIdle: std_logic;
begin
  process(reset, clock)
  begin
    if reset = '1' then
      output <= '0';
      isIdle <= '1';

    elsif rising_edge(clock) then
      if input = '1' then
        if isIdle = '1' then
          isIdle <= '0';
          output <= '1';
        else
          output <= '0';
        end if;
      else
        isIdle <= '1';
        output <= '0';
      end if;
    end if;
  end process;
end architecture;
