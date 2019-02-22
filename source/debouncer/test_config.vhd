library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package test_config is
  constant clockCycles: positive := 20;
  type Debouncer is record
    clock: std_logic;
    reset: std_logic;
    input: std_logic;
    output: std_logic;
  end record;
end package;
