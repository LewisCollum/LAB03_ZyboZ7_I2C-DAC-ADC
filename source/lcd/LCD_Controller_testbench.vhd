-- Automatically generated using the testbench_gen utility.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
library lcd;
use lcd.LCDCommunication.all;
use lcd.LCDInterrupt.all;

entity LCD_Controller_testbench is
end LCD_Controller_testbench;

architecture behavioral of LCD_Controller_testbench is
	component LCD_Controller
		port(
			iclock: in std_logic;
			userControl: in UserControl;
			Interrupt: out LCdInterrupt;
			Control: out LCDControl
		);
	end component;

	signal iclock: std_logic := '0';
	signal userControl: UserControl;
	signal Interrupt: LCdInterrupt;
	signal Control: LCDControl;
begin

    iclock <= not iclock after 4 ns;

	UUT: LCD_Controller
		port map(
			iclock => iclock,
			userControl => userControl,
			Interrupt => Interrupt,
			Control => Control
		);
--Reset : std_logic;
--RS : std_logic;
--RW : std_logic;
--Enable : std_logic;
--nibble : nibble;
	process
	begin
		-- User code here.
		userControl.Reset <= '0';
		userControl.RS <= '0';
		userControl.RW <= '0';
		userControl.Enable <= '0';
		userControl.nibble <= X"1";
		wait for 50 ms;
		
		userControl.Reset <= '0';
        userControl.RS <= '0';
        userControl.RW <= '0';
        userControl.Enable <= '1';
        userControl.nibble <= X"1";
        wait for 1 ms;
        
        userControl.Reset <= '0';
        userControl.RS <= '0';
        userControl.RW <= '0';
        userControl.Enable <= '0';
        userControl.nibble <= X"1";
        wait for 1 ms;

		wait;
	end process;
end behavioral;
