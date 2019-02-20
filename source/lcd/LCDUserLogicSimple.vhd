library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library system_bus;
use system_bus.StateBus.all;
library lcd;
use lcd.LCDInterrupt.LCDInterrupt;
use lcd.LCDCommunication.all;
use lcd.LCDASCII.all;

entity LCDUserLogicSimple is
	port(
		iclock : in std_logic;--50 MHz
        state : in StateBus;
        Interrupt : out LCDInterrupt;
        Control : out LCDControl);
end LCDUserLogicSimple;

architecture behavioral of LCDUserLogicSimple is
	
	type nibble is array(0 to 1) of unsigned(3 downto 0);
    type Line is array (0 to 15) of unsigned(7 downto 0);--array (natural range <>) of unsigned(8 downto 0);
    subtype EnableStateRange is integer range 0 to 2; 
	
	constant LCD_3State_Enable_Time 	: integer := 6000;--6250;--.125 ms (8000 Hz)
	
	signal enable_counter				: integer := 0;
	signal enable_state				    : EnableStateRange;
	signal word_counter					: integer range 1 to 34 := 1;--zero is special case
	signal FirstLine					: Line;-- := (u.I,l.n,l.i,l.t,l.i,l.a,l.l,l.i,l.z,l.i,l.n,l.g,others => c.space);
	signal secondLine					: Line;-- := (others => c.space);
	signal word							: unsigned(8 downto 0);
	signal clk_en 						: std_logic := '0';
	signal charNibble                   : nibble;
	signal WriteStatus                  : LCDInterrupt;
	signal ControllerStatus             : LCDInterrupt;
	signal userControllerInternal       : UserControl;
	signal nibbleSelect                 : integer range 0 to 1 := 1;--High: upper nibble Low: lower nibble (initially will be flipped to 1)
	
begin 

    Interrupt <= ControllerStatus;

	QueSet: process(state, WriteStatus)
	begin
--	if rising_edge(iClock) then
		if WriteStatus.isBusy = '0' then--ControllerStatus.isBusy = '0' and
			case state.system is
				when Initialize =>
					FirstLine	<= (u.I,l.n,l.i,l.t,l.i,l.a,l.l,l.i,l.z,l.i,l.n,l.g,others => c.space);--"Initializing    "
					SecondLine 	<= (others => c.space);												   --"                "
				when fetch =>	
					FirstLine 	<= (u.S,l.e,l.n,l.s,l.o,l.r,c.colon,others => c.space);--"Sensor:         "
					SecondLine 	<= (others => c.space);								   --"                "
					case state.sensor is
						when light =>
							FirstLine(8 to 15)	<= (u.L,u.D,u.R,others => c.space);--"LDR     "
						when pot =>
							FirstLine(8 to 15)	<= (u.P,u.O,u.T,others => c.space);--"POT     "
						when heat =>
							FirstLine(8 to 15)	<= (u.T,l.h,l.e,l.r,u.R,l.e,l.s,others => c.space);--"TherRes "
						when custom =>
							FirstLine(8 to 15)	<= (u.C,l.u,l.s,l.t,l.o,l.m,others => c.space);--"Custom  "
						end case;
					case state.clock is            
						when disabled =>
							SecondLine(0 to 15)	<= (others => c.space);--"                "
						when enabled =>
							SecondLine(0 to 15)	<= (u.C,l.l,l.o,l.c,l.k,c.space,u.O,l.u,l.t,l.p,l.u,l.t,others => c.space);--"Clock Output    "
					end case;
			    when others => null;
			end case;
--		end if;
	end if;
	end process;

	WritingQue: Process(iclock, enable_state, ControllerStatus)
    begin
    if rising_edge(iclock) and ControllerStatus.isBusy = '0' then     
        if enable_counter < LCD_3State_Enable_Time then
            enable_counter <= enable_counter + 1;
        else
            enable_counter <= 0;
            if enable_state < EnableStateRange'high then
                enable_state <= enable_state + 1;
            else
                enable_state <= 0;
                if nibbleSelect = 0 then
                    nibbleSelect <= 1;
                else
                    nibbleSelect <= 0;
                    if word_counter < 34 then--specific to case
                        word_counter <= word_counter + 1;
                    else
                        word_counter <= 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
    end process;
    
    process(WriteStatus)
    begin
    if WriteStatus'event then
        charNibble(0) <= word(3 downto 0);--low nibble
        charNibble(1) <= word(7 downto 4);--high nibble
    end if;
    end process;
    
    process(word_counter, ControllerStatus,iClock)
    begin
    if ControllerStatus.isBusy = '1' then
        WriteStatus.isBusy <= '0';
    elsif word_counter'event then
        WriteStatus.isBusy <= '0';
    else
        WriteStatus.isBusy <= '1';
    end if;
    end process;
	
	LCDenable: process(enable_state, ControllerStatus)--+ nibble select & User.isBusy signal & QueCounter inc.
    begin
        case enable_state is
            when 0 =>
                userControllerInternal.Reset <= '0';
                userControllerInternal.RS <= word(8);
                userControllerInternal.RW <= '0';
                userControllerInternal.nibble <= charNibble(nibbleSelect);
                userControllerInternal.enable <= '0';
            when 1 =>
                userControllerInternal.enable <= '1';
            when 2 =>
                userControllerInternal.enable <= '0';
        end case;
    end process;

	--Que
	with word_counter select
	word <=
		'0'&X"80" 			when 1,--force cursor to beginning of first line
		'1'&FirstLine(0) 	when 2,
		'1'&FirstLine(1) 	when 3,
		'1'&FirstLine(2) 	when 4,
		'1'&FirstLine(3) 	when 5,
		'1'&FirstLine(4) 	when 6,
		'1'&FirstLine(5) 	when 7,
		'1'&FirstLine(6) 	when 8,
		'1'&FirstLine(7) 	when 9,
		'1'&FirstLine(8) 	when 10,
		'1'&FirstLine(9) 	when 11,
		'1'&FirstLine(10) 	when 12,
		'1'&FirstLine(11) 	when 13,
		'1'&FirstLine(12) 	when 14,
		'1'&FirstLine(13) 	when 15,
		'1'&FirstLine(14) 	when 16,
		'1'&FirstLine(15) 	when 17,
		'0'&X"C0" 			when 18,--force cursor to the beginning of second line
		'1'&SecondLine(0) 	when 19,
		'1'&SecondLine(1) 	when 20,
		'1'&SecondLine(2) 	when 21,
		'1'&SecondLine(3) 	when 22,
		'1'&SecondLine(4) 	when 23,
		'1'&SecondLine(5) 	when 24,
		'1'&SecondLine(6) 	when 25,
		'1'&SecondLine(7) 	when 26,
		'1'&SecondLine(8) 	when 27,
		'1'&SecondLine(9) 	when 28,
		'1'&SecondLine(10) 	when 29,
		'1'&SecondLine(11) 	when 30,
		'1'&SecondLine(12) 	when 31,
		'1'&SecondLine(13) 	when 32,
		'1'&SecondLine(14) 	when 33,
		 '1'&SecondLine(15) when 34,
		'0'&X"80" 			when others;

	Inst_LCD_Controller: entity lcd.LCD_Controller
    Port Map( 
		iclock 		       => iclock,
		userControl        => userControllerInternal,
		Interrupt          => ControllerStatus,
		Control            => Control);
		
end behavioral;