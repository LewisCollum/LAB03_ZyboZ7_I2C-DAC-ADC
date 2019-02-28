library ieee;
use ieee.std_logic_1164.all;
use work.i2c_pkg;

entity MasterOut is
  port(
    clock: in std_logic;
    state: in i2c_pkg.State;
    fromSystem: in i2c_pkg.Byte;
    toSlave: out std_logic;
    interrupt: out i2c_pkg.MasterOutInterrupt);
end entity;

architecture behavioral of MasterOut is
begin
  process(clock)
  begin
    if rising_edge(clock) then
      case state.system is
        when i2c_pkg.run =>
          case state.run is
            when i2c_pkg.start =>
            when others => null;
          end case;
        when i2c_pkg.stop =>
        when others => null;
      end case;
    end if;
  end process;
end architecture;
