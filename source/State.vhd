library ieee;
use ieee.numeric_std.all;

package State is
  type System is (initialize, pause, fetch);
  type Sensor is (light, pot, heat, custom);
  type Clock is (disabled, enabled);
  
  type State is record
    system: System;
    sensor: Sensor;
    clock: Clock;
  end record State;    
  
end package State;
