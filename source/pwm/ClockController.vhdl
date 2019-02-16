LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
library system_bus;
use system_bus.DataBus.all;

entity ClockController is
    generic(boardClock : integer := 125_000_000);
	port(
		iClock  	: in std_logic;
		iReset 	 	: in std_logic;
		Data        : in word;
		--iDutyCycle  : in unsigned;
		--iFrequency  : in unsigned;
		oEnable 	: out std_logic);
end ClockController;

architecture behavioral of ClockController is

component PWM IS
    generic(boardClock : integer := 125_000_000);
	port(
		iClock  	: in std_logic;
		iReset 	 	: in std_logic;
		iDutyCycle  : in unsigned(6 downto 0);
		iFrequency	: in unsigned(10 downto 0);
		oEnable 	: out std_logic;
		oPeriod     : out std_logic);
end component;

	signal frequency : unsigned(10 downto 0) := (others => '0');
	signal period_s    : std_logic := '0';
    
begin

    process(period_s)
    begin
        if rising_edge(period_s) then
            frequency <= to_unsigned(to_integer(Data)/(256-1)*1000 + 500,11);--frequency range from 1500 - 500 Hz
        end if;
    end process;

Inst_PWM : PWM
        generic map(boardClock => 125_000_000)
        port map(
            iClock      => iClock,
            iReset      => iReset,
            iDutyCycle  => to_unsigned(50,7),
            iFrequency  => frequency,
            oEnable     => oEnable,
            oPeriod     => period_s);
end behavioral;
