library ieee;
use ieee.std_logic_1164.all;

package I2C is
  type Interrupt is record
    isBusy: std_logic;
  end record Interrupt;
end package I2C;


