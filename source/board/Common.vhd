library ieee;

package Common is
  type Clock is record
    frequency: positive;
    period: time;
  end record;

  constant zyboz7: Clock := (
    frequency => 50e6,
    period => 20 ns);
  
end package;
