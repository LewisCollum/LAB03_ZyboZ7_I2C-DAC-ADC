library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library lcd;
use lcd.LCDInterrupt.LCDInterrupt;
use lcd.LCDCommunication.all;
library system_bus;
use system_bus.StateBus.all;
use system_bus.InterruptBus.all;
library button;
use button.buttonInterrupt.all;
library state;

entity LCD_Test is
    port(
    sysclk  : in std_logic;
    sw      : in unsigned(3 downto 0);
    je      : out unsigned(5 downto 0));
end entity;

architecture test of LCD_Test is

    signal state_s : stateBus;
    signal Interrupt_s : InterruptBus;
    signal LCDInterrupt_s : LCDInterrupt;
    signal Control_s : LCDControl;
    signal buttons   : buttonInterrupt;

begin

    buttons <= (
        reset => sw(3),
        pause => sw(2),
        sensorIncrement => sw(1),
        clockEnable => sw(0));
       
    je(0) <= Control_s.nibble(0);
    je(1) <= Control_s.nibble(1);
    je(2) <= Control_s.nibble(2);
    je(3) <= Control_s.nibble(3);
    je(4) <= Control_s.Enable;
    je(5) <= Control_s.RS;

    unit: entity lcd.LCDUserLogicSimple
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
            
end architecture;
