library ieee;
use ieee.std_logic_1164.all;

package clock_util is
  function frequencyToPeriod(frequency: positive) return time;
  procedure generateClock(signal clock: out std_logic; period: time);
end package clock_util;

package body clock_util is
  function frequencyToPeriod(frequency: positive) return time is
  begin
    return 1 sec / frequency;
  end function frequencyToPeriod;

  procedure generateClock(signal clock: out std_logic; period: time) is
    constant halfPeriod: time := period / 2;
  begin
      loop
        clock <= '1';
        wait for halfPeriod;
        clock <= '0';
        wait for halfPeriod;
      end loop;
  end procedure generateClock;
end package body clock_util;
