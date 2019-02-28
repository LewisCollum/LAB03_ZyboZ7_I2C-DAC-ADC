use work.edge_pkg;

library ieee;
use ieee.std_logic_1164.all;

entity DualInputEdgeDetector is
  port(
    clock: in std_logic;
    reset: in std_logic;
    first: in std_logic;
    second: in std_logic;
    output: out std_logic);
end entity;

architecture rising of DualInputEdgeDetector is
  signal firstEdgeFiltered: std_logic;
  signal secondEdgeFiltered: std_logic;
  signal isFirstDetected: std_logic;
begin
  process(reset, clock)
  begin
    if reset = '1' then
      output <= '0';
      isFirstDetected <= '0';

    elsif rising_edge(clock) then
      if firstEdgeFiltered = '1' then
        isFirstDetected <= '1';
      elsif isFirstDetected = '1' and secondEdgeFiltered = '1' then
        output <= '1';
        isFirstDetected <= '0';
      else
        output <= '0';
      end if;
    end if;
  end process;

  firstEdgeDetector: entity work.EdgeDetector
    port map(
      clock => clock,
      reset => reset,
      input => first,
      output => firstEdgeFiltered);

  secondEdgeDetector: entity work.EdgeDetector
    port map(
      clock => clock,
      reset => reset,
      input => second,
      output => secondEdgeFiltered);
end architecture;
