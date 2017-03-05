library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity frameBuffer is 
port 
(	clk : in std_logic;
	rst : in std_logic;
	fbEn : in std_logic;
	
	-- TODO get player position.
	
	-- gameplay write port
	we : in std_logic;
	
	--gameplay read
	playerPos : in std_logic_vector(7 downto 0);
	
	-- vga read
	vCounter : in std_logic_vector(8 downto 0);
	hCounter : in std_logic_vector(9 downto 0);
	dataOut : out std_logic_vector(2 downto 0);
	
	--swap 
	swap_row1 : in std_logic_vector(3 downto 0);
	swap_col1 : in std_logic_vector(3 downto 0);
	swap_row2 : in std_logic_vector(3 downto 0);
	swap_col2 : in std_logic_vector(3 downto 0);
	data_ready : in std_logic;
	score1 : out std_logic_vector(3 downto 0);
	score10 : out std_logic_vector(3 downto 0)
);
end frameBuffer;

architecture bhv of frameBuffer is


subtype frameBufferElement is std_logic_vector(2 downto 0);
type frameBuffer is array (0 to 11, 0 to 15) of frameBufferElement;

signal fb : frameBuffer;
signal rRow, rCol, wRow1, wCol1, wRow2, wCol2, wRow3, wCol3 : std_logic_vector(3 downto 0);
signal v : std_logic_vector(2 downto 0);
shared variable k, dir, ctt : integer := 0;
signal playerRow, playerCol : std_logic_vector(3 downto 0);
signal checkRow, checkCol : std_logic_vector(3 downto 0);
shared variable one : std_logic_vector(10 downto 0) := (others => '0');
shared variable two : std_logic_vector(10 downto 0) := (others => '0');
shared variable three : std_logic_vector(10 downto 0) := (others => '0');
shared variable countRow : integer := 0; 
shared variable countDel : integer := 0;
signal wAddrG : std_logic_vector(23 downto 0);
signal dataInG : std_logic_vector(2 downto 0); -- sprite ID
signal fbElement : std_logic_vector(10 downto 0);
signal nullRow : std_logic_vector(3 downto 0);
signal nullCol : std_logic_vector(3 downto 0);
signal fillRow : std_logic_vector(3 downto 0);
signal fillCol : std_logic_vector(3 downto 0);
signal fillData : std_logic_vector(2 downto 0); -- sprite ID
signal topRow : std_logic_vector(3 downto 0);
signal topCol : std_logic_vector(3 downto 0);
signal nr : std_logic_vector(3 downto 0);
signal nc : std_logic_vector(3 downto 0);
signal flag : integer;
signal slowdown : integer;
signal init : std_logic;
signal score_t, score10_t : std_logic_vector(3 downto 0);
shared variable countLock : std_logic := '0';
begin

playerRow <= playerPos(7 downto 4);
playerCol <= playerPos(3 downto 0);
wRow1 <= wAddrG(23 downto 20);
wCol1 <= wAddrG(19 downto 16);
wRow2 <= wAddrG(15 downto 12);
wCol2 <= wAddrG(11 downto 8);
wRow3 <= wAddrG(7 downto 4);
wCol3 <= wAddrG(3 downto 0);
score1 <= score_t;
score10 <= score10_t;

-- Define row and column the VGA protocol is accessing.
rRow <= 	"0000" when unsigned(vCounter) < 40 else
		"0001" when unsigned(vCounter) < 80 else
		"0010" when unsigned(vCounter) < 120 else
		"0011" when unsigned(vCounter) < 160 else
		"0100" when unsigned(vCounter) < 200 else
		"0101" when unsigned(vCounter) < 240 else
		"0110" when unsigned(vCounter) < 280 else
		"0111" when unsigned(vCounter) < 320 else
		"1000" when unsigned(vCounter) < 360 else
		"1001" when unsigned(vCounter) < 400 else
		"1010" when unsigned(vCounter) < 440 else
		"1011" when unsigned(vCounter) < 480 else
		"0000";
		
rCol <= 	"0000" when unsigned(hCounter) < 40 else
		"0001" when unsigned(hCounter) < 80 else
		"0010" when unsigned(hCounter) < 120 else
		"0011" when unsigned(hCounter) < 160 else
		"0100" when unsigned(hCounter) < 200 else
		"0101" when unsigned(hCounter) < 240 else
		"0110" when unsigned(hCounter) < 280 else
		"0111" when unsigned(hCounter) < 320 else
		"1000" when unsigned(hCounter) < 360 else
		"1001" when unsigned(hCounter) < 400 else
		"1010" when unsigned(hCounter) < 440 else
		"1011" when unsigned(hCounter) < 480 else
		"1100" when unsigned(hCounter) < 520 else
		"1101" when unsigned(hCounter) < 560 else
		"1110" when unsigned(hCounter) < 600 else
		"1111" when unsigned(hCounter) < 640 else
		"0000";
	

-- Framebuffer Read
dataOut <= fb(conv_integer(rRow), conv_integer(rCol));



-- Iterate over the array. If an empty block is found fill it with the value 
-- of the one above it and set the one above empty.
initialize : process(clk)
variable counter : integer := 0;
begin 
	if rising_edge(clk) then 
		if counter = 0 then 
			for i in 1 to 11 loop	
				for j in 2 to 13 loop
					if fb(i, j) = "000" and not(fb(i - 1, j) = "000") then 
						nullRow <= std_logic_vector(to_unsigned(i - 1, 4));
						nullCol <= std_logic_vector(to_unsigned(j, 4));
						fillRow <= std_logic_vector(to_unsigned(i, 4));
						fillCol <= std_logic_vector(to_unsigned(j, 4));
						fillData <= fb(i - 1, j);
					end if;
				end loop;
			end loop;
			counter := counter + 1;
		elsif counter = 1 then 	
			counter := counter + 1;
		else 
			nullRow <= (others => '0');
			nullCol <= (others => '0');
			counter := 0;
		end if;
	end if;
end process;



process(clk, wRow1, wRow2, wRow3, wCol1, wCol2, wCol3, fillRow, fillCol, nullRow, nullCol, fillData) 
variable temp : std_logic := '0';
variable tempVector : std_logic_vector(2 downto 0) := (1 => '1', others => '0');
variable counter : integer := 0;

variable tempV1, tempV2 : std_logic_vector(2 downto 0);
variable row1, row2, col1, col2 : std_logic_vector(3 downto 0);
variable lockRand, lock : integer := 0;
variable tempNullCol : std_logic_vector(3 downto 0) := (others => '0');
variable tempNullRow : std_logic_vector(3 downto 0) := (others => '0');
begin
	if rising_edge(clk) then
		if rst = '0' then 
			init <= '0';
			counter := 0;
			score10_t <= (others => '0');
			score_t <= (others => '0');
		else
-- Initialize the frame buffer with pseudo-random values.		
		if init = '0' then
			for i in 0 to 11 loop
				for j in 2 to 13 loop
					temp := tempVector(2) xor tempVector(1);
					tempVector(2 downto 1) := tempVector(1 downto 0);
					tempVector(0) := temp;
					if tempVector = "010" then 
						tempVector := "100";
					elsif tempVector = "100" then 
						tempVector := "110";
					end if;
					fb(i, j) <= tempVector;
				end loop;
			end loop;
			init <= '1';
		else
			if data_ready = '1' then 
				-- Only allow a swap when triad is going to be formed. If case below try to predict every possible case.
				if abs(conv_integer(swap_row1)-conv_integer(swap_row2)) <= 1 and abs(conv_integer(swap_col1)-conv_integer(swap_col2)) <= 1 then 
					if (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2 + 1), conv_integer(swap_col2))) and (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2 + 2), conv_integer(swap_col2))) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then 
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					if (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2 - 1), conv_integer(swap_col2))) and (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2 - 2), conv_integer(swap_col2)))then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					if (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 - 1))) and (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 - 2)))then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					if (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 + 1))) and (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 + 2))) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;	
					end if;
					if (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 + 1))) and (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 - 1))) and not (swap_row1 = swap_row2) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					if (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2 + 1), conv_integer(swap_col2))) and (fb(conv_integer(swap_row1), conv_integer(swap_col1)) = fb(conv_integer(swap_row2 - 1), conv_integer(swap_col2))) and not (swap_col1 = swap_col2) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then 
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					
					if (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2 + 1), conv_integer(swap_col2))) and (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2 + 2), conv_integer(swap_col2))) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					if (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2 - 1), conv_integer(swap_col2))) and (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2 - 2), conv_integer(swap_col2))) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then 
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					if (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 - 1))) and (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 - 2))) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					if (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 + 1))) and (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 + 2))) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;	
					end if;
					if (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 + 1))) and (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2), conv_integer(swap_col2 - 1))) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then 
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
					if (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2 + 1), conv_integer(swap_col2))) and (fb(conv_integer(swap_row2), conv_integer(swap_col2)) = fb(conv_integer(swap_row2 - 1), conv_integer(swap_col2))) then	
						fb(conv_integer(swap_row2), conv_integer(swap_col2)) <= fb(conv_integer(swap_row1), conv_integer(swap_col1));
						fb(conv_integer(swap_row1), conv_integer(swap_col1)) <= fb(conv_integer(swap_row2), conv_integer(swap_col2));
						
						if score_t >= 9 and score10_t /= 9 then 
							score_t <= (others => '0');
							if score10_t < 9 then 
								score10_t <= score10_t + 1;
							end if;
						else 
							score_t <= score_t + 1;
						end if;
					end if;
				end if;
			else 
				if we = '1' then
					
					fb(conv_integer(wRow1), conv_integer(wCol1)) <= dataInG;
					fb(conv_integer(wRow2), conv_integer(wCol2)) <= dataInG;
					fb(conv_integer(wRow3), conv_integer(wCol3)) <= dataInG;
					if counter = 0 then 
						for i in 2 to 13 loop
							temp := tempVector(2) xor tempVector(1);
							tempVector(2 downto 1) := tempVector(1 downto 0);
							tempVector(0) := temp;	
							
							if fb(0, i) = "000"  then 
								fb(0, i) <= tempVector;
							end if;
						end loop;
						fb(conv_integer(fillRow), conv_integer(fillCol)) <= fillData;
						counter := counter + 1;
					else 
						fb(conv_integer(nullRow), conv_integer(nullCol)) <= "000";
						counter := 0;
					end if;
				end if;
			end if;
		end if;
	end if;
	end if;
end process;
	
process(clk, checkRow, checkCol) 
variable counter, count_state : integer := 0;
begin
if rst = '0' then 
	slowdown <= 0;
	checkCol <= (others => '0');
	checkRow <= (others => '0');
	one := (others => '0');
	two := (others => '0');
	three := (others => '0');
	wAddrG <= (others => '0');
else 
if rising_edge(clk) then
-- Keep iterating over the array and changing the element around which the check for triads happens.
	if init = '1' then 
	-- Slowdown is added so that the check has time to finish before the check element changes.
		slowdown <= slowdown + 1;
			if slowdown = 10 then 
					if checkCol = 15 then 
						checkCol <= (others => '0');
					else 		
						checkCol <= checkCol + 1;			
					end if;
			slowdown <= 0;
		end if;
		if checkCol = 0 then 
					if checkRow = 11 then
						checkRow <= (others => '0');
					else 		
						checkRow <= checkRow + 1;			
					end if;
		end if;
-- FSM below checks for triads around a specific element in all four diretions.
	case dir is  
		when 0 => 
			one(10 downto 7) := checkRow;
			one(6 downto 3) := checkCol;
			one(2 downto 0) := fb(conv_integer(checkRow), conv_integer(checkCol));
			
			two(10 downto 7) := (checkRow - 1);
			two(6 downto 3) := checkCol;
			two(2 downto 0) := fb(conv_integer(checkRow - 1), conv_integer(checkCol));
			
			three(10 downto 7) := (checkRow - 2);
			three(6 downto 3) := checkCol;
			three(2 downto 0) := fb(conv_integer(checkRow - 2), conv_integer(checkCol));
			
			counter := 0;
			dir := 4;
		when 1 => 
			one(10 downto 7) := checkRow;
				one(6 downto 3) := checkCol;
				one(2 downto 0) := fb(conv_integer(checkRow), conv_integer(checkCol));
				
				two(10 downto 7) := checkRow;
				two(6 downto 3) := checkCol + 1;
				two(2 downto 0) := fb(conv_integer(checkRow), conv_integer(checkCol + 1));
				
				three(10 downto 7) := checkRow;
				three(6 downto 3) := checkCol + 2;
				three(2 downto 0) := fb(conv_integer(checkRow), conv_integer(checkCol + 2));
			
				counter := 1;
				dir := 4;
			
		when 2 => 
			one(10 downto 7) := checkRow;
				one(6 downto 3) := checkCol;
				one(2 downto 0) := fb(conv_integer(checkRow), conv_integer(checkCol));
				
				two(10 downto 7) := (checkRow + 1);
				two(6 downto 3) := checkCol;
				two(2 downto 0) := fb(conv_integer(checkRow + 1), conv_integer(checkCol));
				
					three(10 downto 7) := (checkRow + 2);
				three(6 downto 3) := checkCol;
				three(2 downto 0) := fb(conv_integer(checkRow + 2), conv_integer(checkCol));
				
				counter := 2;
				dir := 4;
		when 3 => 
			one(10 downto 7) := checkRow;
				one(6 downto 3) := checkCol;
				one(2 downto 0) := fb(conv_integer(checkRow), conv_integer(checkCol));
				
				two(10 downto 7) := checkRow;
				two(6 downto 3) := checkCol - 1;
				two(2 downto 0) := fb(conv_integer(checkRow), conv_integer(checkCol - 1));
				
				three(10 downto 7) := checkRow;
				three(6 downto 3) := checkCol - 2;
				three(2 downto 0) := fb(conv_integer(checkRow), conv_integer(checkCol - 2));
				
				counter := 3;
				dir := 4;
		when 4 =>
			if one(2 downto 0) = two(2 downto 0) and one(2 downto 0) = three(2 downto 0) then 
				wAddrG(23 downto 20) <=  three(10 downto 7);
				wAddrG(19 downto 16) <=  three(6 downto 3);
				wAddrG(15 downto 12) <=  two(10 downto 7);
				wAddrG(11 downto 8) <=  two(6 downto 3);
				wAddrG(7 downto 4) <= one(10 downto 7);
				wAddrG(3 downto 0) <= one(6 downto 3);
				dataInG <= "000";
				
				
			else 
				
				wAddrG(23 downto 20) <=  "0000";
				wAddrG(19 downto 16) <=  "0000";
				wAddrG(15 downto 12) <=  "0000";
				wAddrG(11 downto 8) <=  "0000";
				wAddrG(7 downto 4) <= "0000";
				wAddrG(3 downto 0) <= "0000";
				flag <= 0;
			end if;
			
			if counter = 3 then 
				dir := 0;
			else 
				dir := counter + 1;
			end if;
		when others => 
			one := (others => '0');
			two := (others => '0');
			three := (others => '0');
		end case;
	end if;
	end if;
end if;
end process;

end bhv;