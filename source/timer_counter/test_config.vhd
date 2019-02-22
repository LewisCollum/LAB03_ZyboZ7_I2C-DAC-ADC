library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package test_config is
  constant countMax: positive := 20;
  subtype CounterMemory is integer range 0 to countMax;
  type TimerCounter is record
    clock: std_logic;
    reset: std_logic;
    isDone: std_logic;
  end record;
end package;
