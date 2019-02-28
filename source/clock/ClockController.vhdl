LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
library system_bus;
use system_bus.DataBus.all;
library PWM;

entity ClockController is
    generic(boardClock : integer := 125_000_000);
	port(
		iClock  	: in std_logic;
		iReset 	 	: in std_logic;
		Data        : in word;
		oEnable 	: out std_logic);
end ClockController;

architecture behavioral of ClockController is

	constant dutyCylce : unsigned(16 downto 0) := to_unsigned(50_000,17);--50%
	signal frequency   : unsigned(10 downto 0) := to_unsigned(0,11);
	signal period_s    : std_logic := '0';
    
begin

    process(iClock)
    begin
        if rising_edge(iClock) then
            if iReset = '1' then
                frequency <= to_unsigned(0,11);--frequency range from 1500 - 500 Hz
            else
                frequency <= to_unsigned((to_integer(Data)*1000 + 500*(256-1))/(256-1),11);--frequency range from 1500 - 500 Hz
            end if;
        end if;
        if rising_edge(iReset) then
            
        end if;
    end process;

Inst_PWM : entity PWM.PWM
        generic map(boardClock => 125_000_000)
        port map(
            iClock      => iClock,
            iReset      => iReset,
            iDutyCycle  => dutyCylce,--50%
            iFrequency  => frequency,
            oEnable     => oEnable,
            oPeriod     => period_s);
end behavioral;
