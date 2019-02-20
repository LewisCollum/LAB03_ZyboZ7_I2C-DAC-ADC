-- Automatically generated using the testbench_gen utility.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library system_bus;
use system_bus.StateBus.all;
library lcd;
use lcd.LCDInterrupt.all;
use lcd.LCDCommunication.all;
use lcd.LCDASCII.all;

entity LCDUserLogic_testbench is
end LCDUserLogic_testbench;

architecture behavioral of LCDUserLogic_testbench is
	component LCDUserLogic
		port(
			iclock: in std_logic;
			state: in StateBus;
			LCDInterrupt: out LCDInterrupt;
			LCDControl: out LCDControl
		);
	end component;

	signal iclock: std_logic := 0;
	signal state: StateBus;
	signal LCDInterrupt: LCDInterrupt;
	signal LCDControl: LCDControl;
begin
	UUT: LCDUserLogic
		port map(
			iclock => iclock,
			state => state,
			LCDInterrupt => LCDInterrupt,
			LCDControl => LCDControl
		);

	iclock <= not iclock after 4 ns;
	process
	begin
		-- User code here.
		iclock <= ;
		state <= ;
		LCDInterrupt <= ;
		LCDControl <= ;
		wait for 10 ns;

		wait;
	end process;
end behavioral;
