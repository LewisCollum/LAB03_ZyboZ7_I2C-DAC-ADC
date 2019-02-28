library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library lcd;
use lcd.LCDInterrupt.LCDInterrupt;
use lcd.LCDCommunication.all;
library system_bus;
use system_bus.StateBus.all;
use system_bus.InterruptBus.all;
use system_bus.DataBus.all;
library button;
use button.buttonInterrupt.all;
library state;
library pwm;
library clock;

entity Main is
    port(
    sysclk  : in std_logic;
    btn     : in unsigned(3 downto 0);
    je      : out unsigned(5 downto 0);--LCD
    jd      : out unsigned(3 downto 0));
end entity;

architecture behavioral of Main is

    signal state_s : stateBus;
    signal Interrupt_s : InterruptBus;
    signal LCDInterrupt_s : LCDInterrupt;
    signal Control_s : LCDControl;
    signal unfilteredButton : buttonInterrupt;
    signal filteredButton : buttonInterrupt;
    signal Data_s : word;

begin

    --Data_s <= to_unsigned(150,8);
    
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
    
    --jd(0) <= '0';--SDA
    --jd(1) <= '0';--SCL

    Inst_I2C: entity i2c_temp.i2c_master
      generic map(
        input_clk => 125_000_000,
        bus_clk => 100_000)
      port map(
        clk => sysclk,
        reset => filteredButtons.reset,
        ena => '1',
        addr => "1001000",
        rw => '1',
        data_wr => "00000000",
        data_rd => Data_s,
        sda => jd(0),
        scl => jd(1));        
    
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
          generic map(debounceClockCycles => 100_000)
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
              
    Inst_ClockController: entity clock.ClockController
          generic map(boardClock => 125_000_000)
          port map(
              iClock => sysclk,
              iReset => filteredButton.reset,
              Data => Data_s,
              oEnable => jd(3));
end architecture;
