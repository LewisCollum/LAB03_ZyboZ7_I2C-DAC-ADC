library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.LCD;
use work.Button;
use work.I2C; 

package Interrupt is
  --type Button is array (natural range <>) of std_logic;
  
  type Interrupt is record
    button: Button.Interrupt;
    lcd: LCD.Interrupt;
    i2c: I2C.Interrupt;
  end record Interrupt;
  
end package Interrupt;
