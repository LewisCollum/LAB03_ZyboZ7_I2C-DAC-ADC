library system_bus;
use system_bus.StateBus.all;

entity I2CAdapter is
  port(
    clock: in std_logic;
    state: in StateBus;
    i2c_busy: in std_logic;
    address: out std_logic_vector(6 downto 0);
    sendFetch: out std_logic;
    
    );
end entity;

architecture behavioral of I2CAdapter is
  signal busy_prev: std_logic;
  constant slave_addr: std_logic_vector := "1001000";
  constant 
begin
  process(clock, state)
    variable busy_cnt: integer range 0 to 
  begin
    case state.system is
      when fetch =>
        busy_prev <= i2c_busy;
        IF(busy_prev = '0' AND i2c_busy = '1') THEN  
          busy_cnt := busy_cnt + 1;                  
        END IF;
        CASE busy_cnt IS                             
          WHEN 0 =>                                  
            i2c_ena <= '1';                          
            --i2c_addr <= slave_addr;                 
            sendFetch <= '0';                          
            i2c_data_wr <= data_to_write;           
          WHEN 1 =>                                 
            sendFetch <= '1';                          
          WHEN 2 =>                                 
            sendFetch <= '0';                          
            i2c_data_wr <= new_data_to_write;       
            IF(i2c_busy = '0') THEN                 
              data(15 DOWNTO 8) <= i2c_data_rd;     
            END IF;
          WHEN 3 =>                                 
            sendFetch <= '1';                          
          WHEN 4 =>                                 
            i2c_ena <= '0';                         
            IF(i2c_busy = '0') THEN                 
              data(7 DOWNTO 0) <= i2c_data_rd;      
              busy_cnt := 0;                        
              state <= home;                        
            END IF;
          WHEN OTHERS => NULL;
       when others => null;
     end case;
  end process;
end architecture;
