LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
library system_bus;
use system_bus.DataBus.all;
library PWM;

entity ServoController is
    generic(boardClock : integer := 125_000_000);
	port(
		iClock  	: in std_logic;
		iReset 	 	: in std_logic;
		Data        : in word;
		oEnable 	: out std_logic);
end ServoController;

architecture behavioral of ServoController is

	constant frequency : unsigned(10 downto 0) := to_unsigned(50,11);--50 Hz
	signal dutyCycle   : unsigned(16 downto 0) := to_unsigned(0,17);
	signal period_s    : std_logic := '0';
    
begin
    
    process(iClock)
    begin
        if rising_edge(iClock) then
            if iReset = '1' then
                dutyCycle <= to_unsigned(0,17);--5%
            else
                dutyCycle <= to_unsigned(((to_integer(Data)*5_000) + 5_000*(256-1))/(256-1),17);--duty cycle from 5% to 10%
            end if;
        end if;
    end process;

Inst_PWM : entity pwm.PWM
        generic map(boardClock => 125_000_000)
        port map(
            iClock      => iClock,
            iReset      => iReset,
            iDutyCycle  => dutyCycle,
            iFrequency  => frequency,
            oEnable     => oEnable,
            oPeriod     => period_s);
end behavioral;
