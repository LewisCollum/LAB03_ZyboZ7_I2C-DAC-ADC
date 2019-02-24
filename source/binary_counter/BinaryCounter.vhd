library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity BinaryCounter is
  generic(width: positive);
  port(
    increment: in std_logic;
    reset: in std_logic;
    load: in std_logic;
    loadable: in unsigned(width-1 downto 0);
    count: buffer unsigned(width-1 downto 0));
end entity;

architecture behavioral of BinaryCounter is
begin
  process(increment, reset, load) is

    impure function isMaxCount return boolean is
    begin
      return count = count'high;
    end function;

    procedure resetCounter is
    begin
      count <= (others => '0');
    end procedure;  

  begin
    if load = '1' then
      count <= loadable;
    elsif isMaxCount or reset = '1' then
      resetCounter;
    elsif increment = '1' then
      count <= count + 1;
    end if;
  end process;
end architecture;
