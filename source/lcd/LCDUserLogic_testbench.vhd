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
			Interrupt: out LCDInterrupt;
			Control: out LCDControl
		);
	end component;

	signal iclock: std_logic := '0';
	signal state: StateBus;
	signal Interrupt: LCDInterrupt;
	signal Control: LCDControl;
begin

    iclock <= not iclock after 8 ns;

	UUT: LCDUserLogic
		port map(
			iclock => iclock,
			state => state,
			Interrupt => Interrupt,
			Control => Control
		);


	process
	begin
		-- User code here.
		state.System <= initialize;
		state.Sensor <= light;
		state.Clock <= disabled;
		wait for 10 ns;

		wait;
	end process;
end behavioral;
