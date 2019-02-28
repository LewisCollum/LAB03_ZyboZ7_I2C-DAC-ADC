library ieee;
use ieee.std_logic_1164.all;

entity Enabler is
  port(
    input: in std_logic;
    enable: in std_logic;
    output: out std_logic);
end entity;

architecture low of Enabler is
begin
  output <= input when enable = '1' else '0';
end architecture;

architecture high_impedance of Enabler is
begin
  output <= input when enable = '1' else 'Z';
end architecture;

architecture high of Enabler is
begin
  output <= input when enable = '1' else '1';
end architecture;
  
architecture weak_low of Enabler is
begin
  output <= input when enable = '1' else 'L';
end architecture;

architecture weak_high of Enabler is
begin
  output <= input when enable = '1' else 'H';
end architecture;
