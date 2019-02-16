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

  function peripheralsAreBusy(interrupt: InterruptBus) return boolean;
end package;

package body InterruptBus is
  function peripheralsAreBusy(interrupt: InterruptBus) return boolean is
  begin
    if interrupt.lcd.isBusy = '1' or interrupt.i2c.isBusy = '1' then
      return true;
    else
      return false;
    end if;
  end function;
end package body;
