library ieee;
use ieee.std_logic_1164.all;

entity Toggler is
  port(
    toggle: in std_logic;
    reset: in std_logic;
    output: buffer std_logic);
end entity;

architecture resetLow of Toggler is
begin
  process(reset, toggle)
  begin
    if reset = '1' then
      output <= '0';
    elsif rising_edge(toggle) then
      output <= not output;
    end if;
  end process;
end architecture;

architecture resetHigh of Toggler is
begin
  process(reset, toggle)
  begin
    if reset = '1' then
      output <= '1';
    elsif rising_edge(toggle) then
      output <= not output;
    end if;
  end process;
end architecture;
      
