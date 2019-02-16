LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;


entity PWM IS
    generic(boardClock : integer := 125_000_000);
	port(
		iClock  	: in std_logic;
		iReset 	 	: in std_logic;
		iDutyCycle  : in unsigned(6 downto 0);
		iFrequency	: in unsigned(10 downto 0);
		oEnable 	: out std_logic;
		oPeriod     : out std_logic);
end PWM;

architecture behavioral of PWM IS

	signal count : integer := 0;
	signal Enable_s : std_logic := '0';

begin
	
	process (iClock, iReset, iDutyCycle, iFrequency)
	begin
		if iReset = '1' or iDutyCycle'event or iFrequency'event then
			oEnable <= '0';
			count 	<= 0;
		elsif rising_edge(iClock) then
			if count = boardClock/to_integer(iFrequency) then
				count 	<= 0;
				oPeriod <= '1';
			else
				count 	<= count + 1;
				oPeriod <= '0';
			end if;
			
			if count < (boardClock/to_integer(iFrequency))*(to_integer(iDutyCycle)/100) then--amount of time in a period oEnable is high
                oEnable <= '1';
            else
                oEnable <= '0';
            end if;
		end if;
	end process;
	
end behavioral;
