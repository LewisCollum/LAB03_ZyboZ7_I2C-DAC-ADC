library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Wait_Timer is
    Generic( 
           Board_Clock : INTEGER := 125_000_000--Hz
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
    signal oenable_buffer : std_logic := '0';
    
begin

count_max <= ((Board_Clock/(1e6)) * (iwait_time));

oenable <= oenable_buffer;

process(ienable, counter)
begin
    if rising_edge(ienable) then
        count <= true;
    end if;
    if oenable_buffer = '1' then
        count <= false;
    end if;
end process;

wait_timer : process(iclk)
begin
    if rising_edge(iclk) then
        oenable_buffer <= '0';
        if count then
            if counter < count_max then
                counter <= counter + 1;
            else
                oenable_buffer <= '1';
                counter <= 0;
            end if;
        end if;
    end if;
end process;
end Behavioral;
