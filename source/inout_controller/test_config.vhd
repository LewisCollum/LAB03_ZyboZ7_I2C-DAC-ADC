use work.inout_pkg;

library ieee;
use ieee.std_logic_1164.all;

package test_config is
  type InOutController is record
    mode: inout_pkg.Mode;
    sendable: std_logic;
    fetchable: std_logic;
    io: std_logic;
  end record;
end package;
