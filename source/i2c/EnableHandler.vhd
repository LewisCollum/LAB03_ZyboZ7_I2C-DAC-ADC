library toggler, timer_counter, flip_flop, ieee;
use ieee.std_logic_1164.all;

entity EnableHandler is
  port(
    clock: in std_logic;
    resetStart: in std_logic;
    resetFinish: in std_logic;
    enableUnhandled: in std_logic;
    enableHandled: out std_logic);
end entity;

architecture behavioral of EnableHandler is
  signal resetStartDelayed: std_logic;
  signal resetStartToFinish: std_logic;
  signal resetPulse: std_logic;
begin

  resetPulse <= resetStartDelayed or resetFinish;
  enableHandled <= enableUnhandled and not resetStartToFinish;
  
  activeReset: entity toggler.Toggler(resetLow)
    port map(
      toggle => resetPulse,
      reset => resetStart,
      output => resetStartToFinish);

  delayResetStart: entity flip_flop.DelayFlipFlop
    port map(
      clock => clock,
      data => resetStart,
      output => resetStartDelayed);
  
end architecture;
