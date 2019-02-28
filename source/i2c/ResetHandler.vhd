library edge_detector;

library ieee;
use ieee.std_logic_1164.all;

entity ResetHandler is
  port(
    clock: in std_logic;
    resetUnhandled: in std_logic;
    readyToReset: in std_logic;
    resetHandled: buffer std_logic);
end entity;

architecture behavioral of ResetHandler is
begin
  resetHandledWhenReady: entity edge_detector.DualInputEdgeDetector
    port map(
      clock => clock,
      reset => resetHandled,
      first => resetUnhandled,
      second => readyToReset,
      output => resetHandled);
end architecture;
