library ieee;
library vunit_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use vunit_lib.run_pkg.all;
use work.test_config;

entity TestAddressCounter is
  generic(runner_cfg: string);
end entity;

architecture test of TestAddressCounter is
  constant period: time := 20 ns;
  signal clock: std_logic := '0';
  signal addressCounter: test_config.AddressCounter;
begin
  clock <= not clock after period/2;
  addressCounter.clock <= clock;
  
  process
  begin
    test_runner_setup(runner, runner_cfg);
    addressCounter.reset <= '0';
    addressCounter.load <= '0';
    wait for period/4;

    while test_suite loop
      if run("test_SynchronousIncrement") then
        addressCounter.reset <= '1';
        wait for period/2;
        addressCounter.reset <= '0';
        wait for period*4;

        assert addressCounter.address = X"0004";

      elsif run("test_Load") then
        addressCounter.load <= '1';
        addressCounter.loadable <= X"AAAA";
        wait for period/2;
        addressCounter.load <= '0';
        wait for period/2;

        assert addressCounter.address <= X"AAAA";
        
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  unit: entity work.AddressCounter
    generic map(width => test_config.counterWidth)
    port map(
      clock => addressCounter.clock,
      reset => addressCounter.reset,
      load => addressCounter.load,
      loadable => addressCounter.loadable,
      address => addressCounter.address);
    
end architecture;
