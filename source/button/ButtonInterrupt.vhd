library ieee;
use ieee.std_logic_1164.all;

package ButtonInterrupt is
  type ButtonInterrupt is record
    reset: std_logic;
    pause: std_logic;
    sensorIncrement: std_logic;
    clockEnable: std_logic;
  end record;
end package;
