library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library system_bus;
use system_bus.StateBus.all;
library lcd;
use lcd.LCDInterrupt.all;
use lcd.LCDCommunication.all;
use lcd.LCDASCII.all;

entity LCDUserLogic is
	port(
        iclock : in std_logic;--50 MHz
        state : in StateBus;
        LCDInterrupt : out LCDInterrupt;
        LCDControl : out LCDControl);
end LCDUserLogic;

architecture Behavioral of LCDUserLogic is

component LCD_Controller is
    Port ( 
		iclock 		          : in std_logic;
		userControl           : in UserControl;
		lcdInterrupt          : out LCDInterrupt;--H: busy L: Ready
		lcdControlInternal    : out LCDControl);
end component;

    type nibble is array(0 to 1) of unsigned(3 downto 0);
    type Que is array (0 to 34) of unsigned(8 downto 0);

	constant LCD_3State_Enable_Time 	: integer := 6000;--6250;--.125 ms (8000 Hz)
	constant initializeMSG : Que := ('0'&X"80",'1'&u.I,'1'&l.n,'1'&l.i,'1'&l.t,'1'&l.i,'1'&l.a,'1'&l.l,'1'&l.i,'1'&l.z,'1'&l.i,'1'&l.n,'1'&l.g,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,
	                                 '0'&X"C0",'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,(others => '0'));--"Initializing    \n                "
	constant pauseMSG      : Que := ('0'&X"C9",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",
                                     '0'&X"C0",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",(others => '0'));--""
	constant fetchMSG      : Que := ('0'&X"80",'1'&u.S,'1'&l.e,'1'&l.n,'1'&l.s,'1'&l.o,'1'&l.r,
	                                 '0'&X"C0",'1'&u.C,'1'&l.l,'1'&l.k,'1'&c.colon,(others => '0'));--"Sensor:\n Clk:"
	constant lightMSG      : Que := ('0'&X"88",'1'&u.L,'1'&u.D,'1'&u.R,(others => '0'));--"       LDR"
	constant potMSG        : Que := ('0'&X"88",'1'&u.P,'1'&l.o,'1'&l.t,(others => '0'));--"       Pot"
	constant heatMSG       : Que := ('0'&X"88",'1'&u.T,'1'&l.h,'1'&l.e,'1'&l.r,'1'&u.R,'1'&l.e,'1'&l.s,(others => '0'));--"       TherRes"
	constant customMSG     : Que := ('0'&X"88",'1'&u.C,'1'&l.u,'1'&l.s,'1'&l.t,'1'&l.o,'1'&l.m,(others => '0'));--"       Custom"
	constant disabledMSG   : Que := ('0'&X"C4",'1'&u.O,'1'&l.F,'1'&l.F,(others => '0'));--"\n    Off"
	constant enabledMSG    : Que := ('0'&X"C5",'1'&u.O,'1'&l.n,(others => '0'));--"\n     On"
	
	signal userControllerInternal       : UserControl;
	signal LCDStatusController          : LCDInterrupt;
	signal LCDStatusUser                : LCDInterrupt;
	signal enable_counter				: integer := 0;
	signal enable_3state				: integer range 0 to 2 := 0;
--	signal FirstLine			        : std_logic_vector(127 downto 0);
--	signal SecondLine			        : std_logic_vector(127 downto 0);
--	signal LCD_Data			            : std_logic_vector(8 downto 0);
--	signal clk_en 				        : std_logic := '0';
	signal workingQue                   : Que;
	signal charNibble                   : nibble;
	signal QueFinished                  : boolean := false;
	signal QueCounter					: integer range 0 to workingQue'length := 0;--zero is special case
	signal writeFlag                    : boolean := false;
--	signal writeIndex                   : integer := 0;
    signal nibbleSelect                 : integer range 0 to 1 := 0;--High: upper nibble Low: lower nibble (initially will be flipped to 1)
	
begin

    Message : process(state)
    begin
    if LCDStatusUser.isBusy = '0' then
        case state.system is
            when initialize =>
                workingQue <= initializeMSG;
            when pause =>	
                workingQue <= pauseMSG;
            when fetch =>
                workingQue <= fetchMSG;
                --if workingQue finished then
                    case state.sensor is
                        when light =>
                            workingQue <= lightMSG;
                        when pot =>
                            workingQue <= potMSG;
                        when heat =>
                            workingQue <= heatMSG;
                        when custom =>
                            workingQue <= customMSG;
                    end case;
                        workingQue <= pauseMSG;
                    case state.clock is            
                        when disabled =>
                            workingQue <= disabledMSG;
                        when enabled =>
                            workingQue <= enabledMSG;
                    end case;
                --end if;
        end case;
    end if;
    end process;
    
    WritingQue : Process(iclock, state, enable_3state)
    begin
    if LCDStatusController.isBusy = '0' then
        if (state'event) then--will first initialize write???
            writeFlag <= True;
        elsif writeFlag then
            --create counter
            if rising_edge(iclock) then     
                if enable_counter < LCD_3State_Enable_Time then--create clk_en time for enable signal
                    enable_counter <= enable_counter + 1;
--                    clk_en <= '0';
                else
                    enable_counter <= 0;
--                    clk_en <= '1';
                    if enable_3state < 2 then
                        enable_3state <= enable_3state + 1;
                    else
                        enable_3state <= 0;
                    end if;
                end if;
                
                case enable_3state is
                    when 0 =>                
                       charNibble(0) <= WorkingQue(QueCounter)(3 downto 0);--low nibble
                       charNibble(1) <= WorkingQue(QueCounter)(7 downto 4);--high nibble
                       userControllerInternal.RS <= WorkingQue(QueCounter)(8);
                       userControllerInternal.RW <= '0';
                       userControllerInternal.nibble <= charNibble(nibbleSelect);
                       if WorkingQue(QueCounter) = (others => '0') then
                           QueFinished <= true;
                       end if;
                    when 1 =>
                       --data is written to LCD
                    when 2 =>
                end case;
            end if;
        end if;
    end if;
    end process;
    
    Enable : process(enable_3state)--+ nibble select & User.isBusy signal & QueCounter inc.
    begin
        case enable_3state is
            when 0 =>                
                userControllerInternal.enable <= '0';
                --nibble select flip flop
                 if nibbleSelect = 1 then
                   nibbleSelect <= 0;
                   LCDStatusUser.isBusy <= '1';
                else
                   nibbleSelect <= 1;
                   LCDStatusUser.isBusy <= '0';
                   if QueCounter < workingQue'length then
                        QueCounter <= QueCounter + 1;
                   else
                        QueCounter <= 0;
                   end if;
                end if;
            when 1 =>
                userControllerInternal.enable <= '1';
                LCDStatusUser.isBusy <= '1';
            when 2 =>
                userControllerInternal.enable <= '0';
                if nibbleSelect = 1 then
                    LCDStatusUser.isBusy <= '1';
                else
                    LCDStatusUser.isBusy <= '0';
                end if;
        end case;
    end process;
    
--    lcdInterrupt.isBusy <= LCDStatusUser.isBusy AND LCDStatusController.isBusy;

Inst_LCD_Controller: LCD_Controller
    Port Map( 
		iclock 		          => iclock,
		userControl           => userControllerInternal,
		lcdInterrupt          => lcdInterrupt,
		lcdControlInternal    => LCDControl);

end Behavioral;