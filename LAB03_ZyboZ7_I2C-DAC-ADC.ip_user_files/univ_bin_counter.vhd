
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity univ_bin_counter is
   generic(N: integer := 4);
   port(
      clk, reset				: in 	std_logic;
      syn_clr, en, up		: in 	std_logic;
		clk_en 					: in 	std_logic;
		count_min				: in	std_logic_vector(N-1 downto 0);
		count_max				: in 	std_logic_vector(N-1 downto 0);
		count_incr				: in 	std_logic_vector(N-1 downto 0);
		reached_max				: out std_logic;
		reached_min				: out std_logic;
      q							: out std_logic_vector(N-1 downto 0)
   );
end univ_bin_counter;

architecture arch of univ_bin_counter is
   signal r_reg					: unsigned(N - 1 downto 0) := (others => '0');
   signal r_next					: unsigned(N - 1 downto 0) := (others => '0');
	signal above					: unsigned(N downto 0) 		:= (others => '0');
	signal wrap_around_top		: unsigned(N downto 0) 		:= (others => '0');
	signal wrap_around_bottom	: unsigned(N - 1 downto 0) := (others => '0');
begin
	
	above 					<= ('0' & r_reg) + ('0' & unsigned(count_incr));
	wrap_around_top		<= (above - ('0' & unsigned(count_max))) + unsigned(count_min) - 1;
	wrap_around_bottom	<= unsigned(count_max) - unsigned(count_min) + r_reg - unsigned(count_incr) + 1;
	
   -- register
   process(clk,reset)
   begin
      if (reset='1') then
         r_reg <= unsigned(count_min);
      elsif rising_edge(clk) and clk_en = '1' then
         r_reg <= r_next;
      end if;
   end process;
   -- next-state logic
   r_next <= unsigned(count_min)						when syn_clr='1' else
				 wrap_around_top (N - 1 downto 0)	when above > ('0' & unsigned(count_max)) and en ='1' and up='1' else
				 wrap_around_bottom						when (r_reg - unsigned(count_min)) < unsigned(count_incr) and en ='1' and up='0' else
             r_reg + unsigned(count_incr) 		when en ='1' and up='1' else
             r_reg - unsigned(count_incr) 		when en ='1' and up='0' else
             r_reg;
   -- output logic
   q <= std_logic_vector(r_reg);
	reached_min <= '1' when std_logic_vector(r_reg) = std_logic_vector(count_min) else '0';
	reached_max <= '1' when std_logic_vector(r_reg) = std_logic_vector(count_max) else '0';
end arch;

