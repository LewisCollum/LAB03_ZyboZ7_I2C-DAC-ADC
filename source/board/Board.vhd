library ieee;
use ieee.std_logic_1164.all;

package Board is
  type Clock is record
    frequency: positive;
    period: time;  
  end record;
end package;
