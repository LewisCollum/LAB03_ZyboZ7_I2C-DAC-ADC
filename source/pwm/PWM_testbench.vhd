-- Automatically generated using the testbench_gen utility.
LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

entity PWM_testbench is
end PWM_testbench;

architecture behavioral of PWM_testbench is
	component PWM
		generic(
			boardClock: integer
		);
		port(
			iClock: in std_logic;
			iReset: in std_logic;
			iDutyCycle: in unsigned(16 downto 0);
			iFrequency: in unsigned(10 downto 0);
			oEnable: out std_logic;
			oPeriod: out std_logic
		);
	end component;

	signal iClock: std_logic := '0';
	signal iReset: std_logic;
	signal iDutyCycle: unsigned(16 downto 0);
	signal iFrequency: unsigned(10 downto 0);
	signal oEnable: std_logic;
	signal oPeriod: std_logic;
begin

    iClock <= not iClock after 4 ns;

	UUT: PWM
		generic map(
			boardClock => 125_000_000
		)
		port map(
			iClock => iClock,
			iReset => iReset,
			iDutyCycle => iDutyCycle,
			iFrequency => iFrequency,
			oEnable => oEnable,
			oPeriod => oPeriod
		);


	process
	begin
		-- User code here.
		iReset <= '0';
		iDutyCycle <= to_unsigned(50_000,17);
		iFrequency <= to_unsigned(500,11);
		wait for 20 ms;

        iReset <= '1';
		iDutyCycle <= to_unsigned(50_000,17);
		iFrequency <= to_unsigned(500,11);
		wait for 2 ms;
		
		iReset <= '0';
        iDutyCycle <= to_unsigned(90_000,17);
        iFrequency <= to_unsigned(50,11);
        wait for 20 ms;
		wait;
	end process;
end behavioral;
