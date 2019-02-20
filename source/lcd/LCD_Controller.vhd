library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
library lcd;
use lcd.LCDCommunication.all;
use lcd.LCDInterrupt.LCDInterrupt;

entity LCD_Controller is
    Port ( 
		iclock 		  : in std_logic;
		userControl   : in UserControl;
		Interrupt     : out LCdInterrupt;--H: busy L: Ready
		Control    : out LCDControl);
end LCD_Controller;

architecture Behavioral of LCD_Controller is
		
	type ModeStates is (Power_Up_Mode, Initialize_Mode, User_Mode); --All Modes

	constant power_up_time				: integer := 20_000;--20 ms
	constant enable_time           		: integer := 5_000;--5ms (15 ms period for enable pulse)
	constant initialize_instructions    : integer := 14;--que

	signal internal_enable_state		: integer range 0 to 2;
	signal time_counter					: integer := 0;
	signal Mode 						: ModeStates := Power_Up_Mode;
	signal initialize_state			    : integer range 0 to initialize_instructions;--one extra int value for change
	signal Data_s						: unsigned(3 downto 0);
    --wait timmer signals
    signal oenable_s : STD_LOGIC := '0';
    signal ienable_s : STD_LOGIC := '0';
    signal iwait_time_s : INTEGER := power_up_time;--in ns
    
begin
    
    enable_pulse : process(iclock)--and wait time for power up
    begin
    if rising_edge(iclock) then
        case Mode is
            when Power_Up_Mode =>
                iwait_time_s <= power_up_time;--20ms
                ienable_s <= '1';
                if oenable_s = '1' then
                    ienable_s <= '0';
                end if;
            when Initialize_Mode =>
                 iwait_time_s <= enable_time;--5ms
                 ienable_s <= '1';
                 if oenable_s = '1' then
                     ienable_s <= '0';
                 end if;
            when others =>
        end case;
    end if;
    end process;
    
    Mode_Changes : process(iclock)
    begin
    if rising_edge(iclock) then
        case Mode is
            when Power_Up_Mode =>
                if oenable_s = '1' then
                    Mode <= Initialize_Mode;
                end if;
            when Initialize_Mode =>
                if initialize_state = initialize_instructions AND internal_enable_state = 0 then
                    Mode <= User_Mode;
                end if;
            when User_Mode =>
                if userControl.Reset = '1' then
                    Mode <= Initialize_Mode;
                end if;
        end case;
    end if;
    end process;
    
    with initialize_state select
        Data_s <=
            X"3" when 0,--8 bit interface
            X"3" when 1,
            X"3" when 2,
            X"2" when 3,--4 bit interface
            "0010" when 4,
            "1000" when 5,-- function set number of lines: 2 "1XXX"
            "0000" when 6,
            "1000" when 7,--Display, cursor, Blinking off
            "0000" when 8,
            "0001" when 9,--clear display
            "0000" when 10,
            "0110" when 11,--inc cursor to the right when writing and dont shift screen
            "0000" when 12,
            "1100" when 13,--Display on
            "0000" when 14;--Nothing
        
    process(iclock, Mode, internal_enable_state)--Mode process
    begin
    if rising_edge(iclock) then
        case Mode is
            when Power_Up_Mode =>
                Control.RS			<= '0';
                Control.RW			<= '0';
                Interrupt.isBusy		<= '1';
                Control.enable 	    <= '0';
                Control.nibble 		<= X"3";
            when Initialize_Mode =>
                Control.nibble 		<= Data_s;
                Control.RS			<= '0';
                Control.RW			<= '0';
                Interrupt.isBusy	<= '1';
                case internal_enable_state is
                    when 0 => 	
                        Control.enable <= '0';
                    when 1 =>
                        Control.enable <= '1';
                    when 2 =>
                        Control.enable <= '0';			
                end case;
                if oenable_s = '1' then
                    if internal_enable_state < 2 then
                         internal_enable_state <= internal_enable_state + 1;
                     else
                         internal_enable_state <= 0;
                         initialize_state <= initialize_state + 1;
                     end if;
                end if; 
            when User_Mode =>
                Control.nibble 		<= UserControl.nibble;
                Control.RS			<= UserControl.RS;
                Control.RW			<= '0';
                Interrupt.isBusy		<= '0';
                Control.enable 	    <= UserControl.enable;
        end case;
    end if;
    end process;

Inst_Wait_Timer : entity work.Wait_Timer
    Generic Map ( 
           Board_Clock => 125_000_000)--ns
    Port Map ( 
           iclk => iclock,
           ienable => ienable_s,
           iwait_time => iwait_time_s,
           oenable => oenable_s);
end Behavioral;