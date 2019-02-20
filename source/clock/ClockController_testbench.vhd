-- Automatically generated using the testbench_gen utility.
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library system_bus;
use system_bus.DataBus.all;

entity ClockController_testbench is
end ClockController_testbench;

architecture behavioral of ClockController_testbench is
	component ClockController
		generic(
			boardClock: integer
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

	UUT: ClockController
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
		Data <= to_unsigned(200,8);
		wait for 20 ms;
		
		iReset <= '1';
        Data <= to_unsigned(200,8);
        wait for 1 ms;
        
        iReset <= '0';
        Data <= to_unsigned(10,8);
        wait for 20 ms;

		wait;
	end process;
end behavioral;
