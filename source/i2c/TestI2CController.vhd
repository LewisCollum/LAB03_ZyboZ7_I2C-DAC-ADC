library ieee, vunit_lib, testing;
use work.i2c_pkg;
use testing.clock_util;
use testing.pulse_util;
use vunit_lib.run_pkg.all;

entity TestI2CController is
  generic(runner_cfg: string);
end entity;

architecture test of TestI2CController is
  constant period: time := 20 ns;
  signal unit: i2c_pkg.I2CController;
begin
  process
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
      
      if run("waveform") then
        wait for period*10;
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  clock_util.generateClock(unit.clock, period);
end architecture;

