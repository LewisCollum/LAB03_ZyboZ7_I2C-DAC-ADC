LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library i2c_temp;


Entity I2C_UserLogic is
    generic (
        slave_addr: std_logic_vector(6 downto 0) := "1001000";
        count_max : integer := 10);
    port(
        iclk : in std_logic;
        reset : in std_logic;
        data_wr : in std_logic_vector(7 downto 0);
        busy : out std_logic;
        data_rd : out std_logic_vector(7 downto 0);
        oSDA : inout std_logic;
        oSCL : inout std_logic);
end I2C_UserLogic;

Architecture Behavioral of I2C_UserLogic is
--    constant startTime : integer := 16383;
--    type ModeStates is (startMode, writingMode, ReadingMode, stopMode);
--    signal Mode : ModeStates := startMode;
--    signal reset_n : std_logic;
--    signal open_s : std_logic;
--    signal enable : std_logic;
--    signal RW : std_logic;
--    signal Master_busy : std_logic;
--    signal startCounter : integer := 0;
    
--    signal data_wr_prev : std_logic_vector(7 downto 0);
--    signal Master_busy_prev : std_logic;

    signal busy_prev: std_logic;
    signal i2c_busy: std_logic;
    signal i2c_ena: std_logic;
    signal i2c_rw: std_logic;
    signal i2c_data_wr: std_logic_vector(7 downto 0);
    signal data_to_write: std_logic_vector(7 downto 0);
    signal i2c_data_rd: std_logic_vector(7 downto 0);

Begin

    process(sysclk, state_s)
        begin
            if rising_edge(sysclk) then
                case state_s.sensor is
                    when light => 
                        data_to_write <= "00000000";
                    when pot =>
                        data_to_write <= "00000011";
                    when heat =>
                        data_to_write <= "00000001";
                    when custom =>
                        data_to_write <= "00000010";
                end case;
            end if;
        end process;

    process(sysclk)
        variable busy_cnt: integer range 0 to 2 := 0;
    begin
      busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
        IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
          busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
        END IF;
        CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
          WHEN 0 =>                                  --no command latched in yet
            i2c_ena <= '1';                            --initiate the transaction
            --i2c_addr <= slave_addr;                    --set the address of the slave
            i2c_rw <= '0';                             --command 1 is a write
            i2c_data_wr <= data_to_write;              --data to be written
          WHEN 1 =>                                  --1st busy high: command 1 latched, okay to issue command 2
            i2c_rw <= '1';                             --command 2 is a read (addr stays the same)
            Data_s <= unsigned(i2c_data_rd);
--            i2c_ena <= '0';                            --deassert enable to stop transaction after command 4
--            IF(i2c_busy = '0') THEN                    --indicates data read in command 4 is ready
--              Data_s <= unsigned(i2c_data_rd);           --retrieve data from command 4
--              busy_cnt := 0;                             --reset busy_cnt for next transaction
----              state <= home;                             --transaction complete, go to next state in design
--            END IF;         
--          WHEN 2 =>                                  --2nd busy high: command 2 latched, okay to issue command 3
--            i2c_rw <= '0';                             --command 3 is a write
--            i2c_data_wr <= new_data_to_write;          --data to be written
--            IF(i2c_busy = '0') THEN                    --indicates data read in command 2 is ready
--              data(15 DOWNTO 8) <= i2c_data_rd;          --retrieve data from command 2
--            END IF;
          WHEN 3 =>                                  --3rd busy high: command 3 latched, okay to issue command 4
            i2c_rw <= '1';                             --command 4 is read (addr stays the same)
--          WHEN 4 =>                                  --4th busy high: command 4 latched, ready to stop
            i2c_ena <= '0';                            --deassert enable to stop transaction after command 4
            IF(i2c_busy = '0') THEN                    --indicates data read in command 4 is ready
              Data_s <= unsigned(i2c_data_rd);           --retrieve data from command 4
              busy_cnt := 0;                             --reset busy_cnt for next transaction
              --state <= home;                             --transaction complete, go to next state in design
            END IF;
          WHEN OTHERS => NULL;
        end case;
    end process;

--    stateChange : process(iclk, reset)
--    begin
--    if reset = '1' then
--        Mode <= startMode;
--        enable <= '0';
--    end if;
--    if rising_edge(iclk) then      
--        case Mode is
--            when startMode =>
--                if startCounter < startTime then
--                    startCounter <= startCounter +1;
--                    Mode <= startMode;
--                else
--                    Mode <= writingMode;
--                end if;
--            when writingMode =>
                
--            when ReadingMode =>
                
--            when stopMode =>
                
--            when others => null;
--        end case;
--    end if;
--    end process;
    
--    process(mode)--what to do inside each mode
--    begin
--        case Mode is
--                when startMode =>
--                    enable <= '0';
--                when writingMode =>
--                    enable <= '1';
--                    RW <= '0';
--                when ReadingMode =>
                
--                when stopMode =>
                
--                when others => null;
--            end case;
--    end process;

--    process(iclk)--monitor signals data_wr & Master_busy
--    begin 
--        if rising_edge(iclk) then 
--            data_wr_prev <= data_wr;
--            Master_busy_prev <= Master_busy;
--        end if;
--    end process;

--    reset_n <= not reset;
--    busy <= Master_busy;

Inst_I2C: entity i2c_temp.i2c_master
      generic map(
        input_clk => 125_000_000,
        bus_clk => 100_000)
      port map(
        clk => sysclk,
        reset => filteredButton.reset,
        ena => i2c_ena,
        addr => "1001000",
        rw => i2c_rw,
        data_wr => i2c_data_wr,
        busy => i2c_busy,
        unsigned(data_rd) => i2c_data_rd,
        sda => jd(0),
        scl => jd(1));   

--Inst_I2C_Master: entity i2c_temp.i2c_master
--        generic map(
--            input_clk => 125000000,
--            bus_clk => 100000)
--        port map(
--            clk         => iclk,
--            reset       => reset_n, -- active low reset
--            ena         => enable, -- latch in command
--            addr        => slave_addr, -- address of target slave
--            rw          => RW, -- '0' is write, '1' is read
--            data_wr     => data_wr, -- data to write to slave
--            busy        => Master_busy, --indicates transaction in progress
--            data_rd     => data_rd, -- data read from slave
--            ack_error   => open_s, -- flag if improper acknowledge from slave
--            sda         => oSDA, -- serial data output of the i2c bus
--            scl         => oSCL); -- serial clock output of the i2c bus

end Behavioral;