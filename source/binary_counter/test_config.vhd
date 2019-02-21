library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package test_config is
  constant counterWidth: positive := 16;
  subtype CounterMemory is unsigned(counterWidth-1 downto 0);
  type BinaryCounter is record
    increment: std_logic;
    reset: std_logic;
    load: std_logic;
    loadable: CounterMemory;
    count: CounterMemory;
  end record;
end package;
