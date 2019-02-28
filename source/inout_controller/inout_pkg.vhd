library ieee;
use ieee.std_logic_1164.all;

package inout_pkg is
  type ModeName is (removed, fetch, send);
  
  type Mode is record
    isRemoved: std_logic;
    isFetch: std_logic;
    isSend: std_logic;
  end record;

  function setMode(modeName: ModeName) return Mode;
end package;

package body inout_pkg is
  function setMode(modeName: ModeName) return Mode is
    variable output: Mode;
  begin
    case modeName is
      when removed =>
        output := (isRemoved => '1', others => '0');
      when fetch =>
        output := (isFetch => '1', others => '0');
      when send =>
        output := (isSend => '1', others => '0');
    end case;

    return output;
  end function;
end package body;
