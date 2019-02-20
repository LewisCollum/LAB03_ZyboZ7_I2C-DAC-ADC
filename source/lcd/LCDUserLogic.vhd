library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library system_bus;
use system_bus.StateBus.all;
library lcd;
use lcd.LCDInterrupt.LCDInterrupt;
use lcd.LCDCommunication.all;
use lcd.LCDASCII.all;

entity LCDUserLogic is
	port(
        iclock : in std_logic;--50 MHz
        state : in StateBus;
        Interrupt : out LCDInterrupt;
        Control : out LCDControl);
end LCDUserLogic;

architecture Behavioral of LCDUserLogic is

    type nibble is array(0 to 1) of unsigned(3 downto 0);
    type Que is array (0 to 34) of unsigned(8 downto 0);--array (natural range <>) of unsigned(8 downto 0);

	constant LCD_3State_Enable_Time 	: integer := 6000;--6250;--.125 ms (8000 Hz)
	constant initializeMSG : Que := ('0'&X"80",'1'&u.I,'1'&l.n,'1'&l.i,'1'&l.t,'1'&l.i,'1'&l.a,'1'&l.l,'1'&l.i,'1'&l.z,'1'&l.i,'1'&l.n,'1'&l.g,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,
	                                 '0'&X"C0",'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space, others => (others => '0'));--"Initializing    \n                "
	constant fetchMSG      : Que := ('0'&X"80",'1'&u.S,'1'&l.e,'1'&l.n,'1'&l.s,'1'&l.o,'1'&l.r,'1'&c.colon,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space, others => (others => '0'));--"Sensor:      "
	constant lightMSG      : Que := ('0'&X"88",'1'&u.L,'1'&u.D,'1'&u.R, others => (others => '0'));--"       LDR"
	constant potMSG        : Que := ('0'&X"88",'1'&u.P,'1'&l.o,'1'&l.t, others => (others => '0'));--"       Pot"
	constant heatMSG       : Que := ('0'&X"88",'1'&u.T,'1'&l.h,'1'&l.e,'1'&l.r,'1'&u.R,'1'&l.e,'1'&l.s, others => (others => '0'));--"       TherRes"
	constant customMSG     : Que := ('0'&X"88",'1'&u.C,'1'&l.u,'1'&l.s,'1'&l.t,'1'&l.o,'1'&l.m,others => (others => '0'));--"       Custom"
	constant disabledMSG   : Que := ('0'&X"C0",'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space,'1'&c.space, others => (others => '0'));--"\n            "
	constant enabledMSG    : Que := ('0'&X"C0",'1'&u.C,'1'&l.l,'1'&l.o,'1'&l.c,'1'&l.k,'1'&c.space,'1'&u.O,'1'&l.u,'1'&l.t,'1'&l.p,'1'&l.u,'1'&l.t, others => (others => '0'));--"\nClock Output"
	
	signal userControllerInternal       : UserControl;
	signal StatusController             : LCDInterrupt;
	signal StatusUser                   : LCDInterrupt;
	signal enable_counter				: integer := 0;
	signal enable_3state				: integer range 0 to 2 := 0;
	signal workingQue                   : Que := initializeMSG;
	signal charNibble                   : nibble;
	signal QueCounter					: integer range 0 to workingQue'length := 0;--zero is special case
	signal writeFlag                    : boolean := false;
	
	signal QueFinished                  : boolean := false;
	signal systemFlag                   : boolean := true;
	signal sensorFlag                   : boolean := true;
	signal clockFlag                    : boolean := true;
	signal resetQueCounter              : boolean := false;--tells the QueCounter to reset to zero
	signal QueStart                     : boolean := true;
	
    signal nibbleSelect                 : integer range 0 to 1 := 0;--High: upper nibble Low: lower nibble (initially will be flipped to 1)
	
begin

--    Message : process(state)--sets que messages
--        begin
--        if state.system'event then
--            systemFlag <= true;
--            sensorFlag <= false;
--            clockFlag <= false;
--        elsif state.sensor'event then
--            sensorFlag <= true;
--        elsif state.clock'event then
--            clockFlag <= true;
--        end if;
--        if StatusUser.isBusy = '0' and QueFinished then--the system is not writing and the que is finished writing message
--            if systemFlag then
--                case state.system is
--                    when initialize =>
--                        workingQue <= initializeMSG;
--                    when fetch =>
--                        workingQue <= fetchMSG;
--                    when others => null;
--                end case;
--            end if;
--            if sensorFlag then
--                case state.sensor is
--                    when light =>
--                        workingQue <= lightMSG;
--                    when pot =>
--                        workingQue <= potMSG;
--                    when heat =>
--                        workingQue <= heatMSG;
--                    when custom =>
--                        workingQue <= customMSG;
--                end case;
--            end if;
--            if clockFlag then
--                case state.clock is            
--                    when disabled =>
--                        workingQue <= disabledMSG;
--                    when enabled =>
--                        workingQue <= enabledMSG;
--                end case;
--            end if;
--        end if;
--        end process;

    Message : process(state)--sets que messages
    begin
    if state.system'event then
        systemFlag <= true;
    elsif state.sensor'event then
        sensorFlag <= true;
    elsif state.clock'event then
        clockFlag <= true;
    end if;
    if StatusUser.isBusy = '0' and QueFinished then
        QueStart <= true;
        if SystemFlag then
            case state.system is
                when initialize =>
                    workingQue <= initializeMSG;
                when fetch =>
                    workingQue <= fetchMSG;
                    if QueFinished then
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
                        if QueFinished then--fix
                            case state.clock is            
                                when disabled =>
                                    workingQue <= disabledMSG;
                                when enabled =>
                                    workingQue <= enabledMSG;
                            end case;
                        end if;
                    end if;
    --                when others => null;
            end case;
        end if;
    end if;
    end process;
    
    WritingQue : Process(iclock, state, enable_3state, StatusController)
    begin
    if StatusController.isBusy = '0' then
        if rising_edge(iclock) then     
            if statusUser.isBusy = '0' and QueFinished then--Que is not busy (rest)
                enable_counter <= 0;
                enable_3state <= 0;
            elsif enable_counter < LCD_3State_Enable_Time then--create clk_en time for enable signal
                enable_counter <= enable_counter + 1;
            else
                enable_counter <= 0;
                if enable_3state < 2 then
                    enable_3state <= enable_3state + 1;
                else
                    enable_3state <= 0;
                end if;
            end if;
            
            if QueStart then
                QueFinished <= False;
            end if;
            
            if WorkingQue(QueCounter) = X"00" then
                QueFinished <= True;
            end if;
            
            charNibble(0) <= WorkingQue(QueCounter)(3 downto 0);--low nibble
            charNibble(1) <= WorkingQue(QueCounter)(7 downto 4);--high nibble
        end if;
    end if;
    end process;
    
    Enable : process(enable_3state)--+ nibble select & User.isBusy signal & QueCounter inc.
    begin
        case enable_3state is
            when 0 =>
                userControllerInternal.RS <= WorkingQue(QueCounter)(8);
                userControllerInternal.RW <= '0';
                userControllerInternal.nibble <= charNibble(nibbleSelect);
                userControllerInternal.enable <= '0';
                --nibble select flip flop
                 if nibbleSelect = 1 then
                   nibbleSelect <= 0;
                   StatusUser.isBusy <= '1';
                else
                   nibbleSelect <= 1;
                   StatusUser.isBusy <= '0';
                   if QueFinished then
                       QueCounter <= 0;
                   elsif QueCounter < workingQue'length then
                       QueCounter <= QueCounter + 1;
                   else
                       QueCounter <= 0;
                   end if;
                end if;
            when 1 =>
                userControllerInternal.enable <= '1';
                StatusUser.isBusy <= '1';
            when 2 =>
                userControllerInternal.enable <= '0';
                if nibbleSelect = 1 then
                    StatusUser.isBusy <= '1';
                else
                    StatusUser.isBusy <= '0';
                end if;
        end case;
    end process;
    
--    lcdInterrupt.isBusy <= LCDStatusUser.isBusy AND LCDStatusController.isBusy;

Inst_LCD_Controller: entity lcd.LCD_Controller
    Port Map( 
		iclock 		       => iclock,
		userControl        => userControllerInternal,
		Interrupt          => Interrupt,
		Control            => Control);

end Behavioral;