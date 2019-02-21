library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package test_config is
  constant counterWidth: positive := 16;
  subtype CounterMemory is unsigned(counterWidth-1 downto 0);
  type AddressCounter is record
    clock: std_logic;
    reset: std_logic;
    load: std_logic;
    loadable: counterMemory;
    address: counterMemory;
  end record;
end package;
