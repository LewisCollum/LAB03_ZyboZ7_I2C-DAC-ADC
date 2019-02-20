-- Automatically generated using the testbench_gen utility.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Wait_Timer_testbench is
end Wait_Timer_testbench;

architecture behavioral of Wait_Timer_testbench is
	component Wait_Timer
		generic(
			Board_Clock: INTEGER := 125_000_000
		);
		port(
			iclk: in STD_LOGIC;
			ienable: in STD_LOGIC;
			iwait_time: in INTEGER;
			oenable: out STD_LOGIC
		);
	end component;

	signal iclk: STD_LOGIC := '0';
	signal ienable: STD_LOGIC;
	signal iwait_time: INTEGER;
	signal oenable: STD_LOGIC;
begin

    iclk <= not iclk after 4 ns;
    
	UUT: Wait_Timer
		generic map(
			Board_Clock => 125_000_000
		)
		port map(
			iclk => iclk,
			ienable => ienable,
			iwait_time => iwait_time,
			oenable => oenable
		);


	process
	begin
		-- User code here.
		ienable <= '0';
		iwait_time <= 10;
		wait for 100 ns;
		
		ienable <= '1';
        iwait_time <= 20_000;
        wait for 21 ms;
        
        ienable <= '0';
        iwait_time <= 20_000;
        wait for 8 ns;
        
        ienable <= '1';
        iwait_time <= 5_000;
        wait for 6 ms;

		wait;
	end process;
end behavioral;
