library ieee;
use ieee.std_logic_1164.all;

package Button is
  type Interrupt is record
    reset: std_logic;
    pause: std_logic;
    sensorIncrement: std_logic;
    clockEnable: std_logic;
  end record Interrupt;
end package Button;
