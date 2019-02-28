library ieee;
use ieee.std_logic_1164.all;

entity DFlipFlop is
  port(
    clock: in std_logic;
    data: in std_logic;
    output: out std_logic);
end entity;

architecture behavioral of DFlipFlop is
begin
  process(clock)
  begin
    output <= data when rising_edge(clock);
  end process;
end architecture;
