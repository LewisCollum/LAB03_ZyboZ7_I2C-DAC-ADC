library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package LCDCommunication is
	subtype nibble is unsigned(3 downto 0);
	
	type UserControl is record
		Reset : std_logic;
		RS : std_logic;
		RW : std_logic;
		Enable : std_logic;
		nibble : nibble;
	 end record;
	 
	 type LCDControl is record
		RS : std_logic;
		RW : std_logic;
		Enable : std_logic;
		nibble : nibble;
	 end record;
end package;
