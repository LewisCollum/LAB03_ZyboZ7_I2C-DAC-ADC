library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library system_bus;
use system_bus.StateBus.all;

library toggler;
library debouncer;
library edge_detector;
library enabler;

use work.ButtonInterrupt.ButtonInterrupt;

entity ButtonController is
  generic(debounceClockCycles: positive);
  port(
    clock: in std_logic;
    reset: in std_logic;
    state: in StateBus;
    unfilteredButton: in ButtonInterrupt;
    filteredButton: out ButtonInterrupt);
end entity;

architecture behavioral of ButtonController is
  
  type DebounceButton is record
    reset: std_logic;
    sensorIncrement: std_logic;
    clockEnable: std_logic;
  end record;
  
  type ToggleButton is record
    clockEnable: std_logic;
  end record;

  type PulseButton is record
    sensorIncrement: std_logic;
  end record;

  signal debounced: DebounceButton;
  signal toggled: ToggleButton;
  signal pulsed: PulseButton;

  signal isFetching: std_logic;

begin

  stateMachine: process(state)
  begin
    case state.system is
      when fetch => isFetching <= '1';
      when others => isFetching <= '0';
    end case;
  end process;
  
  filteredButton.reset <= debounced.reset;
  
  setSensorIncrementEnabler: entity enabler.Enabler(low)
    port map(
      input => pulsed.sensorIncrement,
      enable => isFetching,
      output => filteredButton.sensorIncrement);

  setClockEnableEnabler: entity enabler.Enabler(low)
    port map(
      input => toggled.clockEnable,
      enable => isFetching,
      output => filteredButton.clockEnable);

  setDebouncedReset: entity debouncer.Debouncer
    generic map(clockCycles => debounceClockCycles)
    port map(
      clock => clock,
      reset => reset,
      input => unfilteredButton.reset,
      output => debounced.reset);

  setDebouncedSensorIncrement: entity debouncer.Debouncer
    generic map(clockCycles => debounceClockCycles)
    port map(
      clock => clock,
      reset => reset,
      input => unfilteredButton.sensorIncrement,
      output => debounced.sensorIncrement);

  setDebouncedClockEnable: entity debouncer.Debouncer
    generic map(clockCycles => debounceClockCycles)
    port map(
      clock => clock,
      reset => reset,
      input => unfilteredButton.clockEnable,
      output => debounced.clockEnable);
     
  setClockEnableToggle: entity toggler.Toggler(resetLow)
    port map(
      toggle => debounced.clockEnable,
      reset => reset,
      output => toggled.clockEnable);

  setPulsedSensorIncrement: entity edge_detector.EdgeDetector(rising)
    port map(
      clock => clock,
      reset => reset,
      input => debounced.sensorIncrement,
      output => pulsed.sensorIncrement);
end architecture;  
