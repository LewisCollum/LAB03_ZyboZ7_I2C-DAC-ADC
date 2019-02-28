library IEEE, lcd, i2c_temp, system_bus, button, state, pwm, clock;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use lcd.LCDInterrupt.LCDInterrupt;
use lcd.LCDCommunication.all;
use system_bus.StateBus.all;
use system_bus.InterruptBus.all;
use system_bus.DataBus.all;
use button.buttonInterrupt.all;

entity Main is
    port(
    sysclk  : in std_logic;
    btn     : in unsigned(3 downto 0);
    je      : out unsigned(5 downto 0);--LCD
    jd      : inout unsigned(3 downto 0));
end entity;

architecture behavioral of Main is

    signal state_s : stateBus;
    signal Interrupt_s : InterruptBus;
    signal LCDInterrupt_s : LCDInterrupt;
    signal Control_s : LCDControl;
    signal unfilteredButton : buttonInterrupt;
    signal filteredButton : buttonInterrupt;
    signal Data_s : word;

    signal busy_prev: std_logic;
    signal i2c_busy: std_logic;
    signal i2c_busy_prev: std_logic;
    signal i2c_ena: std_logic;
    signal i2c_rw: std_logic;
    signal i2c_data_wr: std_logic_vector(7 downto 0);
    signal i2c_data_wr_prev: std_logic_vector(7 downto 0);
    signal data_to_write: std_logic_vector(7 downto 0);
    signal i2c_data_rd: unsigned(7 downto 0);
    
    type state_type is (start, read, write, stop);
    signal i2c_State: state_type := start;
    signal nack: std_logic;
    signal address: std_logic_vector(6 downto 0);
    signal Cnt : integer := 16383;
    signal not_reset : std_logic;
    signal clockControllerEnable: std_logic;
    
begin

    not_reset <= not filteredButton.reset;
    
    unfilteredButton.reset <= btn(0);
    unfilteredButton.sensorIncrement <= btn(1);
    unfilteredButton.clockEnable <= btn(2);
    
    Interrupt_s.button <= filteredButton;
       
    je(0) <= Control_s.nibble(0);
    je(1) <= Control_s.nibble(1);
    je(2) <= Control_s.nibble(2);
    je(3) <= Control_s.nibble(3);
    je(4) <= Control_s.Enable;
    je(5) <= Control_s.RS;
    
    --I2C
    process(sysclk, state_s)
    begin
        if rising_edge(sysclk) then
            case state_s.sensor is
                when light => 
                    data_to_write <= "01000000";
                when pot =>
                    data_to_write <= "01000011";
                when heat =>
                    data_to_write <= "01000001";
                when custom =>
                    data_to_write <= "01000010";
            end case;
        end if;
    end process;
    i2c_data_wr <= data_to_write;
    
    StateChange: process(sysclk, filteredButton.reset)
    begin 
        if filteredButton.reset = '1' then 
            i2c_State <= start;
            i2c_ena <= '0';
        elsif rising_edge(sysclk) then 
            case i2c_State is 
                when start =>
                    if Cnt /= 0 then 
                        Cnt <= Cnt-1;
                        i2c_State <= start;
                        i2c_ena <= '0';
                    else 
                        i2c_ena <= '1';
                        address <= "1001000";
                        i2c_rw <= '0';
                        i2c_State <= write;
                    end if;
                    
                when write =>
                    if (i2c_busy_prev/=i2c_busy and i2c_busy='0') then
                        i2c_rw <= '1';
                        i2c_State <= read;
                    end if;
                    
                when read => 
                    if (i2c_data_wr /= i2c_data_wr_prev) then 
                        i2c_ena <= '0';
                        i2c_State <= stop;
                    elsif (i2c_busy_prev/=i2c_busy and i2c_busy='0') then
                          Data_s <= i2c_data_rd; --logic vector
                          i2c_State <= read; 
                    end if;
                      
                 when stop =>
                    i2c_State <= start;
                    i2c_ena <= '0';
              end case;
         end if;
    end process;
      
    process(sysclk)
    begin 
        if rising_edge(sysclk) then 
            i2c_data_wr_prev <= i2c_data_wr;
            i2c_busy_prev <= i2c_busy;
        end if;
    end process;
    
    Inst_I2C: entity i2c_temp.i2c_master
      generic map(
        input_clk => 125_000_000,
        bus_clk => 100_000)
      port map(
        clk => sysclk,
        reset_n => not_reset,
        ena => i2c_ena,
        addr => address,
        rw => i2c_rw,
        data_wr => i2c_data_wr,
        busy => i2c_busy,
        unsigned(data_rd) => i2c_data_rd,
        ack_error=>nack,
        sda => jd(0),
        scl => jd(1));
    --End I2C        
    
    Inst_LCD: entity lcd.LCDUserLogicSimple
    port map(
        iclock => sysclk,
        state => state_s,
        Interrupt => LCDInterrupt_s,
        Control => Control_s);
    
    Inst_StateController: entity state.StateController
          port map(
            clock => sysclk,
            interrupt => Interrupt_s,
            state => state_s);
            
    Inst_ButtonController: entity button.ButtonController
          generic map(debounceClockCycles => 500_000)
          port map(
              clock => sysclk,
              reset => filteredButton.reset,
              state => state_s,
              unfilteredButton => unfilteredButton,
              filteredButton => filteredButton);
    
    Inst_ServoController: entity pwm.ServoController
          generic map(boardClock => 125_000_000)
          port map(
              iClock => sysclk,
              iReset => filteredButton.reset,
              Data => Data_s,
              oEnable => jd(2));
     
     process(sysclk)
     begin
        if state_s.clock = enabled or filteredButton.reset = '1' then
            clockControllerEnable <= '0'; 
        else
            clockControllerEnable <= '1';
        end if;
     end process;
              
    Inst_ClockController: entity clock.ClockController
          generic map(boardClock => 125_000_000)
          port map(
              iClock => sysclk,
              iReset => clockControllerEnable,
              Data => Data_s,
              oEnable => jd(3));
end architecture;
