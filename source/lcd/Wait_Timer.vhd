library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Wait_Timer is
    Generic( 
           Board_Clock : INTEGER := 50_000_000--ns
           );
    Port ( 
           iclk : in STD_LOGIC;
           ienable : in STD_LOGIC;
           iwait_time : in INTEGER;--in ns
           oenable : out STD_LOGIC
           );
end Wait_Timer;

architecture Behavioral of Wait_Timer is
    
    signal counter : INTEGER := 0;
    signal count_max : INTEGER := 0;
    signal ienable_prev : STD_LOGIC := '0';
    signal count : boolean := false;
    
begin

count_max <= (Board_Clock * iwait_time) / (1e9);

wait_timer : process(iclk, ienable)
begin
if rising_edge(iclk) then
    ienable_prev <= ienable;
    if ienable = '1' AND ienable_prev = '0' then--ienable rising edge
        count <= true;
    end if;

    if count then
        if counter < count_max then
            oenable <= '0';
            counter <= counter + 1;
        else
            oenable <= '1';
            counter <= 0;
            count <= false;
        end if;
    end if;
end if;
end process;
end Behavioral;
