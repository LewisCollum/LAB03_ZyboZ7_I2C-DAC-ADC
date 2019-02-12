library ieee;
use ieee.std_logic_1164.all;

package LCDInterrupt is
  type LCDInterrupt is record
    isBusy: std_logic;
  end record;
end package;
