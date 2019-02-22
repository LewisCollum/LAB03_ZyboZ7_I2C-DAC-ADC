

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity btn_tb is
    
end btn_tb;

architecture Behavioral of btn_tb is
component btn_debounce_toggle is
GENERIC (
    CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"000F");
    Port ( BTN_I : in STD_LOGIC;
           CLK : in STD_LOGIC;
           BTN_O : out STD_LOGIC;
           TOGGLE_O : out STD_LOGIC);
 end component;
 
    signal BTN_I : std_logic;
    signal CLK : std_logic :='0';
    signal BTN_O : std_logic;
    signal TOGGLE_O :  std_logic;

begin

    ints_btn_debounce_toggle: btn_debounce_toggle
        port map (
            BTN_I => BTN_I,
            CLK => CLK,
            BTN_O => BTN_O,
            TOGGLE_O => TOGGLE_O
            );
    clk <= not clk after 10 ns;
    process
      begin
        BTN_I <='1';
        wait for 2 ms;
        BTN_I <='0';
        wait for 1 ms;
        BTN_I <= '1';
        wait for 4 ms;
		  BTN_I <= '0';
        wait for 4 ms;
    end process;
    
    
    
    

end Behavioral;
