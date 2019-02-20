-- Automatically generated using the testbench_gen utility.
LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
library system_bus;
use system_bus.DataBus.all;

entity ServoController_testbench is
end ServoController_testbench;

architecture behavioral of ServoController_testbench is
	component ServoController
		generic(
			boardClock: integer := 125_000_000
		);
		port(
			iClock: in std_logic;
			iReset: in std_logic;
			Data: in word;
			oEnable: out std_logic
		);
	end component;

	signal iClock: std_logic := '0';
	signal iReset: std_logic;
	signal Data: word;
	signal oEnable: std_logic;
begin

    iClock <= not iClock after 4 ns;

	UUT: ServoController
		generic map(
			boardClock => 125_000_000
		)
		port map(
			iClock => iClock,
			iReset => iReset,
			Data => Data,
			oEnable => oEnable
		);


	process
	begin
		-- User code here.
		iReset <= '0';
		Data <= to_unsigned(0,8);
        wait for 8 us;
		
		Data <= to_unsigned(50,8);
		wait for 40 ms;
		
		Data <= to_unsigned(255,8);
        wait for 40 ms;
        
        Data <= to_unsigned(10,8);
        wait for 40 ms;

		wait;
	end process;
end behavioral;
