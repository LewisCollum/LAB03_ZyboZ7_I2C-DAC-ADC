library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library lcd;
use lcd.LCDInterrupt.LCDInterrupt;
library button;
use button.ButtonInterrupt.ButtonInterrupt;
library i2c;
use i2c.I2CInterrupt.I2CInterrupt;

package InterruptBus is
  type InterruptBus is record
    button: ButtonInterrupt;
    lcd: LCDInterrupt;
    i2c: I2CInterrupt;
  end record;
end package;
