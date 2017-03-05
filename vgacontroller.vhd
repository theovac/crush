library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity vgaController is 
port
(	clk : in std_logic;
	rst : in std_logic;
	
	-- VGA protocol
	r : out std_logic_vector(3 downto 0); 
	g : out std_logic_vector(3 downto 0); 
	b : out std_logic_vector(3 downto 0);
	hsync : out std_logic;
	vsync : out std_logic;
	
	-- Read
	dataIn : in std_logic_vector(39 downto 0);
	rowCount : out std_logic_vector(8 downto 0);
	colCount : out std_logic_vector(9 downto 0);
	
	-- Player position
	playerPos : in std_logic_vector(7 downto 0);
	
	id : in std_logic_vector(2 downto 0);
	data_ready : in std_logic;
	swapRow1 : in std_logic_vector(3 downto 0);
	swapCol1 : in std_logic_vector(3 downto 0);
	swapRow2 : in std_logic_vector(3 downto 0);
	swapCol2 : in std_logic_vector(3 downto 0);
	
	scoreOnesData : in std_logic_vector(39 downto 0);
	scoreTensData : in std_logic_vector(39 downto 0)
);
end vgaController;

architecture bhv of vgaController is
	signal pxClk : std_logic;
	signal hCounter : std_logic_vector(9 downto 0);
	signal vCounter : std_logic_vector(8 downto 0);
	signal col : std_logic_vector(9 downto 0);
	signal pRow, pCol : std_logic_vector(3 downto 0);
	signal playerRow : std_logic_vector(3 downto 0);
	signal playerCol : std_logic_vector(3 downto 0);
begin

rowCount <= vCounter;
colCount <= hCounter;

playerRow <= playerPos(7 downto 4);
playerCol <= playerPos(3 downto 0);

process(clk)
begin
	if rising_edge(clk) then
		pxClk <= not pxClk;
	end if;
end process;

-- Process that increments hCounter
process(clk, rst)
begin
	if rst = '0' then
		hCounter <= (others => '0');
	elsif rising_edge(clk) then
		if pxClk = '1' then 
			if hCounter = 800 then
				hCounter <= (others => '0');
			else 
				hCounter <= hCounter + 1;
			end if;
		end if;
	end if;
end process;

	
-- Process that drives hsync
process(clk, rst, pxClk, hCounter)
begin
	if rising_edge(clk) then 
		if pxClk = '1' then
			if hCounter > 656 and hCounter < 753 then
				hsync <= '0';
			else
				hsync <= '1';
			end if;
	  end if;
	end if;
end process;

-- Process that increments vCounter	
process(clk, rst)
begin
	if rst = '0' then
		vCounter <= (others => '0');
	elsif rising_edge(clk) then
		if pxClk = '1' and hCounter = "0000000000" then
			if vCounter = 600 then
				vCounter <= (others => '0');
			else 
				vCounter <= vCounter + 1;	
			end if;
		end if;
	end if;
end process;	
	
-- Process that drives vsync
process(clk, rst, pxClk, vCounter)
begin
	if rising_edge(clk) then 
		if pxClk = '1' then
			if vCounter > 491 and vCounter < 494 then
				vsync <= '0';
			else
				vsync <= '1';
			end if;
		end if;
	end if;
end process;

process(hCounter) 
begin
	if hCounter < 40 then
		col <= hCounter;
	elsif hCounter < 80 then
		col <= hCounter - 40;
	elsif hCounter < 120 then
		col <= hCounter - 80;
	elsif hCounter < 160 then
		col <= hCounter - 120;
	elsif hCounter < 200 then
		col <= hCounter - 160;
	elsif hCounter < 240 then
		col <= hCounter - 200;
	elsif hCounter < 280 then
		col <= hCounter - 240;
	elsif hCounter < 320 then
		col <= hCounter - 280;
	elsif hCounter < 360 then
		col <= hCounter - 320;
	elsif hCounter < 400 then
		col <= hCounter - 360;
	elsif hCounter < 440 then
		col <= hCounter - 400;
	elsif hCounter < 480 then
		col <= hCounter - 440;
	elsif hCounter < 520 then
		col <= hCounter - 480;
	elsif hCounter < 560 then
		col <= hCounter - 520;
	elsif hCounter < 600 then
		col <= hCounter - 560;
	elsif hCounter < 640 then
		col <= hCounter - 600;
	else col <= (others => '0');
end if;
end process;

pRow <= 	
		"0000" when vCounter < 40 else
		"0001" when vCounter < 80 else
		"0010" when vCounter < 120 else
		"0011" when vCounter < 160 else
		"0100" when vCounter < 200 else
		"0101" when vCounter < 240 else
		"0110" when vCounter < 280 else
		"0111" when vCounter < 320 else
		"1000" when vCounter < 360 else
		"1001" when vCounter < 400 else
		"1010" when vCounter < 440 else
		"1011" when vCounter < 480 else
		"0000";

pCol <= 	"0000" when hCounter < 40 else
		"0001" when hCounter < 80 else
		"0010" when hCounter < 120 else
		"0011" when hCounter < 160 else
		"0100" when hCounter < 200 else
		"0101" when hCounter < 240 else
		"0110" when hCounter < 280 else
		"0111" when hCounter < 320 else
		"1000" when hCounter < 360 else
		"1001" when hCounter < 400 else
		"1010" when hCounter < 440 else
		"1011" when hCounter < 480 else
		"1100" when hCounter < 520 else
		"1101" when hCounter < 560 else
		"1110" when hCounter < 600 else
		"1111" when hCounter < 640 else
		"0000";
		
process(hCounter, vCounter, pRow, pCol, rst, clk, dataIn, scoreOnesData, scoreTensData) 
begin
if rising_edge(clk) then 
  if hCounter >= 639 then
	 r <= "0000";
	 g <= "0000";
	 b <= "0000";
  elsif vCounter >= 479 then
	 r <= "0000";
	 g <= "0000";
	 b <= "0000";
  else
    if pCol > 13 or pCol < 2 then 
	   r <= "0000";
		g <= "0000";
		b <= "0000";	
    elsif dataIn(conv_integer(col)) = '1' then		
		if (playerRow = pRow and playerCol = pCol) then 
			r <= "1111";
			g <= "1111";
			b <= "1111";
		elsif (pCol = swapCol1 and pRow = swapRow1)  and data_ready = '0' then 
			r <= "1111";
			g <= "1111";
			b <= "1111";
		elsif id = "001" then 
			r <= "0000";
			g <= "0000";
			b <= "1111";
		elsif id = "010" then 
			r <= "0000";
			g <= "1111";
			b <= "0000";
		elsif id = "011" then 
			r <= "1111";
			g <= "1111";
			b <= "0000";
		elsif id = "100" then 
			r <= "1111";
			g <= "0000";
			b <= "1111";
		elsif id = "101" then 
			r <= "1111";
			g <= "0000";
			b <= "0000";
		elsif id = "110" then 
			r <= "1100";
			g <= "1001";
			b <= "1111";
		elsif id = "111" then 
			r <= "0011";
			g <= "1101";
			b <= "1101";
		else  
			r <= "0000";
			g <= "0000";
			b <= "0000";
		end if;
	else 
		r <= "0000";
		g <= "0000";
		b <= "0000";
	 end if;
  end if;
end if;
end process;
end bhv;
  
