library ieee;
use ieee.std_logic_1164.all;

package I2CInterrupt is
  type I2CInterrupt is record
    isBusy: std_logic;
  end record;
end package;


