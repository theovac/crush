library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity swap is

port (	
		clk : in std_logic;
		rst : in std_logic;
		button : in std_logic;
		playerPos : in std_logic_vector(7 downto 0);
		swap_row1 : out std_logic_vector(3 downto 0);
		swap_col1 : out std_logic_vector(3 downto 0);
		swap_row2 : out std_logic_vector(3 downto 0);
		swap_col2 : out std_logic_vector(3 downto 0);
		data_ready : out std_logic;
		data_valid : in std_logic
);
end swap;

architecture RTL of swap is

signal swap_reg : std_logic_vector(15 downto 0);
signal signal_b1,signal_b2,signal_b3, final_button : std_logic;
signal counter : integer;
begin

-- edge detector
process(clk)
begin
	if rising_edge(clk) then
		signal_b1 <= button;
		signal_b2 <= signal_b1;
		signal_b3 <= signal_b2;
	end if;
end process;
--button
final_button <= (signal_b3 and (not signal_b2));

process(clk,rst)
begin
	if rst = '0' then
		counter <= 0;
		swap_row1 <= (others => '0');
		swap_col1 <= (others => '0');
		swap_row2 <= (others => '0');
		swap_col2 <= (others => '0');
	elsif rising_edge(clk) then
		data_ready <= '0';
		if final_button = '1' then
			if counter = 0 then
				swap_row1 <= playerPos(7 downto 4);
				swap_col1 <= playerPos(3 downto 0);
				counter <= counter + 1;
			else 
				swap_row2 <= playerPos(7 downto 4);
				swap_col2 <= playerPos(3 downto 0);
				counter <= counter + 1;
				data_ready <= '1';
				counter <= 0;
			end if;
		end if;
	end if;
end process;

			




end RTL;