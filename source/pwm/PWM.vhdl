LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

entity PWM IS
    generic(boardClock : integer := 125_000_000);
	port(
		iClock  	: in std_logic;
		iReset 	 	: in std_logic;
		iDutyCycle  : in unsigned(16 downto 0);--range: 100_000-0 is 100% to 0%
		iFrequency	: in unsigned(10 downto 0);
		oEnable 	: out std_logic;
		oPeriod     : out std_logic);
end PWM;

architecture behavioral of PWM IS

	signal count : integer := 0;
	signal Enable_s : std_logic := '0';
	signal iDutyCycle_s : unsigned(16 downto 0) := (others => '0');--range: 100_000-0 is 100% to 0%
	signal iFrequency_s	: unsigned(10 downto 0) := (others => '0');
	signal period : integer := 0;
	signal dutyCycle : integer := 50_000;

begin
	process (iClock)
	begin
	   if rising_edge(iClock) then
	       if iFrequency = to_unsigned(0,11) then
	           period <= 0;
	       else
	           period <= boardClock/to_integer(iFrequency);
	       end if;
	       if iDutyCycle = to_unsigned(0,17) then
                dutyCycle <= 0;
           else
                dutyCycle <= period/(100_000 / (to_integer(iDutyCycle)));--amount of time in a period oEnable is high
           end if;
	       iDutyCycle_s <= iDutyCycle;
	       iFrequency_s <= iFrequency;
	   end if;
	end process;
	
	process (iClock, iReset, iDutyCycle, iFrequency)
	begin
		if iReset = '1' then
			oEnable <= '0';
			count 	<= 0;
			oPeriod <= '0';
		elsif iDutyCycle /= iDutyCycle_s or iFrequency /= iFrequency_s then
            oEnable <= '0';
            count     <= 0;
            oPeriod <= '1';
		elsif rising_edge(iClock) then
			if count = period then
				count 	<= 0;
				oPeriod <= '1';
			else
				count 	<= count + 1;
				oPeriod <= '0';
			end if;
			if count < dutyCycle then
                oEnable <= '1';
            else
                oEnable <= '0';
            end if;
		end if;
	end process;
	
end behavioral;
