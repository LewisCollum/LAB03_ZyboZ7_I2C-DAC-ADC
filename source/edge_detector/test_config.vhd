library ieee;
use ieee.std_logic_1164.all;

package test_config is
  type EdgeDetector is record
    clock: std_logic;
    reset: std_logic;
    input: std_logic;
    output: std_logic;
  end record;

  type DualInputEdgeDetector is record
    clock: std_logic;
    reset: std_logic;
    first: std_logic;
    second: std_logic;
    output: std_logic;
  end record;  
end package;
