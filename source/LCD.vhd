library ieee;
use ieee.std_logic_1164.all;

package LCD is
  type Interrupt is record
    isBusy: std_logic;
  end record Interrupt;
end package LCD;
