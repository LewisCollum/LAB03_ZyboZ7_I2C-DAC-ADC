library ieee;
use ieee.std_logic_1164.all;

package pulse_util is
  procedure highPulseForTime(signal output: out std_logic; duration: time);
  procedure lowPulseForTime(signal output: out std_logic; duration: time);
end package;

package body pulse_util is
  procedure highPulseForTime(signal output: out std_logic; duration: time) is
  begin
    output <= '1';
    wait for duration;
    output <= '0';
  end procedure highPulseForTime;
  
  procedure lowPulseForTime(signal output: out std_logic; duration: time) is
  begin
    output <= '0';
    wait for duration;
    output <= '1';
  end procedure lowPulseForTime;
end package body;
