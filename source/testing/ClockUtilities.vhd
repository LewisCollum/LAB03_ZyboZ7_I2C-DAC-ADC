library ieee;
use ieee.std_logic_1164.all;

package ClockUtilities is
  function frequencyToPeriod(frequency: positive) return time;
  procedure generateClock(signal clock: out std_logic; frequency: integer);
end package ClockUtilities;

package body ClockUtilities is
  function frequencyToPeriod(frequency: positive) return time is
  begin
    return 1 sec / frequency;
  end function frequencyToPeriod;

  procedure generateClock(signal clock: out std_logic; frequency: integer) is
    constant period: time := 1 sec / frequency;
    constant halfPeriod: time := period / 2;
  begin
      loop
        clock <= '1';
        wait for halfPeriod;
        clock <= '0';
        wait for halfPeriod;
      end loop;
  end procedure generateClock;
end package body ClockUtilities;


