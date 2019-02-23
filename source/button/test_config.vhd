library ieee;
use ieee.std_logic_1164.all;

library system_bus;
use system_bus.StateBus.all;

use work.ButtonInterrupt.all;

package test_config is
  type ButtonController is record
    clock: std_logic;
    reset: std_logic;
    state: StateBus;
    unfilteredButton: ButtonInterrupt;
    filteredButton: ButtonInterrupt;
  end record;
end package;
