library ieee;
use ieee.std_logic_1164.all;

library system_bus;
use system_bus.StateBus.all;

use work.ButtonInterrupt.all;
use work.test_config;

library testing;
use testing.clock_util;
use testing.pulse_util;

library vunit_lib;
use vunit_lib.run_pkg.all;


entity TestButtonController is
  generic(runner_cfg: string);
end entity;

architecture test of TestButtonController is
  constant period: time := 20 ns;
  signal buttonController: test_config.ButtonController;
  
begin
  process
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
      buttonController.unfilteredButton <= (others => '0');
      wait for period*3/4;
      pulse_util.highPulseForTime(buttonController.reset, period);   

      if run("test_InitializeState_ClockEnableStaysLow") then
        buttonController.state.system <= initialize;
        pulse_util.highPulseForTime(buttonController.unfilteredButton.clockEnable, period);
        wait for period;

        assert buttonController.filteredButton.clockEnable = '0';
        
      elsif run("test_InitializeState_SensorIncrementStaysLow") then
        buttonController.state.system <= initialize;
        pulse_util.highPulseForTime(buttonController.unfilteredButton.sensorIncrement, period);
        wait for period;

        assert buttonController.filteredButton.sensorIncrement = '0';
        
      elsif run("test_FetchState_EnableClockToggles") then
        buttonController.state.system <= fetch;
        pulse_util.highPulseForTime(buttonController.unfilteredButton.clockEnable, period*2);
        wait for period;

        assert buttonController.filteredButton.clockEnable = '1';
        
       elsif run("test_FetchState_SensorIncrementPulses") then
         buttonController.state.system <= fetch;
         pulse_util.highPulseForTime(buttonController.unfilteredButton.sensorIncrement, period);
         wait for period;

         assert buttonController.filteredButton.sensorIncrement = '1';
         wait for period;
         assert buttonController.filteredButton.sensorIncrement = '0';
         wait for period;
         assert buttonController.filteredButton.sensorIncrement = '0'; 
        
      end if;
    end loop;
    
    test_runner_cleanup(runner);
  end process;

  unit: entity work.ButtonController
    generic map(debounceClockCycles => 10)
    port map(
      clock => buttonController.clock,
      reset => buttonController.reset,
      state => buttonController.state,
      unfilteredButton => buttonController.unfilteredButton,
      filteredButton => buttonController.filteredButton);

  clock_util.generateClock(buttonController.clock, period);
end architecture;
