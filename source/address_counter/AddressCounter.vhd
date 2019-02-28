library ieee;
library binary_counter;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AddressCounter is
  generic(constant width: positive);
  port(
    clock: in std_logic;
    reset: in std_logic;
    load: in std_logic;
    loadable: in unsigned(width-1 downto 0);
    address: out unsigned(width-1 downto 0));
end entity;

architecture behavioral of AddressCounter is
  type Synchronizable is record
    reset: std_logic;
    load: std_logic;
  end record;

  signal synchronized: Synchronizable;

begin
  process(clock)
  begin
    if rising_edge(clock) then
      synchronized.reset <= reset;
      synchronized.load <= load;
    end if;
  end process;
  
  counter: entity binary_counter.BinaryCounter
    generic map(width => width)
    port map(
      increment => clock,
      reset => synchronized.reset,
      load => synchronized.load,
      loadable => loadable,
      count => address);
      
end behavioral;
