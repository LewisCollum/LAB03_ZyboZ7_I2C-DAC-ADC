library ieee;
use ieee.numeric_std.all;

package StateBus is
  type System is (initialize, fetch, reset);
  type Sensor is (light, pot, heat, custom);
  type Clock is (disabled, enabled);
  
  type StateBus is record
    system: System;
    sensor: Sensor;
    clock: Clock;
  end record;    
end package;
