entity ResetHandler is
  port(
    reset: in std_logic;
    isReadyToReset: in std_logic;

end entity;

architecture behavioral of ResetHandler is
  signal toggle: st
begin
  process
  begin
    toggle = '1' when reset = '1'
  end process;

  resetToggle: entity toggler.Toggler(resetLow)
    port map(
      toggle => reset or 
      
end architecture;
