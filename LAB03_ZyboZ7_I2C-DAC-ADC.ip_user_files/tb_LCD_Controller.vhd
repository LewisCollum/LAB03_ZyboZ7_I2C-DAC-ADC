library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tb_LCD_Controller is
end tb_LCD_Controller;

architecture arch of tb_LCD_Controller is

component LCD_Controller is
port(
	iClk 			: IN std_logic;
	iReset_n		: IN std_logic;
	iRS			: IN std_logic;--H: sending data L: sending instructions
	iRW			: IN std_logic;--H: Read L: Write
	iEnable		: IN std_logic;
	iData			: IN std_logic_vector(7 downto 0);--MSB: is RS followed by RW
	oBusy			: OUT std_logic;--H: busy L: Ready
	oRS			: OUT std_logic;--H: sending data L: sending instructions
	oRW			: OUT std_logic;--H: Read L: Write
	oEnable		: OUT std_logic;
	oData			: OUT std_logic_vector(7 downto 0)--could be made inout
	);
end component;

	signal iClk 		: std_logic := '0';
	signal iReset_n	: std_logic;
	signal iRS			: std_logic;--H: sending data L: sending instructions
	signal iRW			: std_logic;--H: Read L: Write
	signal iEnable		: std_logic;
	signal iData		: std_logic_vector(7 downto 0);--MSB: is RS followed by RW
	signal oBusy		: std_logic;--H: busy L: Ready
	signal oRS			: std_logic;--H: sending data L: sending instructions
	signal oRW			: std_logic;--H: Read L: Write
	signal oEnable		: std_logic;
	signal oData		: std_logic_vector(7 downto 0);--could be made inout

begin
iClk<= not iClk after 10 ns;
DUT: LCD_Controller
	port map(
		iClk 			=> iClk,
		iReset_n		=> iReset_n,
		iRS			=> iRS,
		iRW			=> iRW,
		iEnable		=> iEnable,
		iData			=> iData,
		oBusy			=> oBusy,
		oRS			=> oRS,
		oRW			=> oRW,
		oEnable		=> oEnable,
		oData			=> oData
		);	
process
begin
	iReset_n		<= '1';--not being used (active low)
	iRW			<= '0';--hardcoded write
	
	iRS			<= '0';
	iEnable		<= '0';
	iData			<= X"00";
	wait for 20 ms;

	iRS			<= '0';
	iEnable		<= '0';
	iData			<= X"80";
	wait for 40 ms;

	iRS			<= '0';
	iEnable		<= '0';
	iData			<= X"80";
	wait for 40 ms;
wait;
	
end process;
end arch;