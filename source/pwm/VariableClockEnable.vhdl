LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;


entity VariableClockEnable IS
    generic(boardClock : integer := 125_000_000);
	port(
		iClock  	: in std_logic;
		iReset 	 	: in std_logic;
		iFrequency	: in unsigned;
		oEnable 	: out std_logic);
end VariableClockEnable;

architecture behavioral of VariableClockEnable IS

	signal count : integer := 0;

begin
	
	process (iClock, iReset)
	begin
		if iReset = '1' then
			oEnable <= '0';
			count 	<= 0;
		elsif rising_edge(iClock) then
			if count = boardClock/to_integer(iFrequency) then
				oEnable <= '1';
				count 	<= 0;
			else
				oEnable <= '0';
				count 	<= count + 1;
			end if;
		end if;
	end process;
	
end behavioral;
