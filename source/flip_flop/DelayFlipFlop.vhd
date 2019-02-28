library ieee;
use ieee.std_logic_1164.all;

entity DelayFlipFlop is
  port(
    clock: in std_logic;
    data: in std_logic;
    output: out std_logic);
end entity;

architecture behavioral of DelayFlipFlop is
  type DFlipFlop is record
    data: std_logic;
    output: std_logic;
  end record;

  type DFlipFlops is array(0 to 2) of DFlipFlop;

  signal flipFlops: DFlipFlops;

begin
  flipFlops(0).data <= data;  
  flipFlops(1).data <= flipFlops(0).output;
  output <= flipFlops(1).output;

  createDFlipFlops: for i in 0 to 1 generate
    createDFlipFlop: entity work.DFlipFlop
      port map(
        clock => clock,
        data => flipFlops(i).data,
        output => flipFlops(i).output);
    end generate;
end architecture;
