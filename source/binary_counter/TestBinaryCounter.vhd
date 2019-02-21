library ieee;
library vunit_lib;
use vunit_lib.run_pkg.all;
use work.test_config;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TestBinaryCounter is
  generic(runner_cfg: string);
end entity;

architecture test of TestBinaryCounter is
  constant period: time := 20 ns;
  constant trivialLoadable: test_config.CounterMemory := x"AAAA";
  signal clock: std_logic := '0'; 
  signal counter: test_config.BinaryCounter;
begin
  clock <= not clock after period;
  counter.increment <= clock;

  main: process
  begin
    test_runner_setup(runner, runner_cfg);
    wait for period/4;
    
    while test_suite loop
      counter.load <= '0';
      counter.reset <= '0';
      wait for period/4;
      
      if run("test_LoadLoadable") then
        counter.loadable <= trivialLoadable;
        counter.load <= '1';
        wait for period/2;
        
        assert counter.count = trivialLoadable;

      elsif run("test_IncrementCount") then
        counter.reset <= '1';
        wait for period;
        counter.reset <= '0';
        wait for period;

        assert counter.count = X"0001";
        
      elsif run("test_resetAtMaxCount") then
        counter.load <= '1';
        counter.loadable <= (others => '1');
        wait for period;
        counter.load <= '0';
        wait for period;

        assert counter.count = X"0000";
        
      end if;
    end loop;
    
    wait for period;
    test_runner_cleanup(runner);
  end process;

  unit: entity work.BinaryCounter
    generic map(width => 16)
    port map(
      increment => counter.increment,
      reset => counter.reset,
      load => counter.load,
      loadable => counter.loadable,
      count => counter.count);
      
end architecture;
