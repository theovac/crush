library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity movement is
port (
		clk : in std_logic;
		rst : in std_logic;
		playerPos : out std_logic_vector(7 downto 0);		
		go_up : in std_logic;
		go_down : in std_logic;
		go_left : in std_logic;
		go_right : in std_logic;
		data_valid : in std_logic
);
end movement;

architecture RTL of movement is

TYPE State_type IS (A, B, C, D, E);  -- Define the states
        SIGNAL fsm_state : State_Type;    -- Create a signal that uses 


signal signal_up1, clk2 : std_logic;
signal signal_up2 : std_logic;
signal signal_up3 : std_logic;
signal signal_down1 : std_logic;
signal signal_down2 : std_logic;
signal signal_down3 : std_logic;
signal signal_left1 : std_logic;
signal signal_left2 : std_logic;
signal signal_left3 : std_logic;
signal signal_right1 : std_logic;
signal signal_right2 : std_logic;
signal signal_right3 : std_logic;
signal final_down : std_logic;
signal final_up : std_logic;
signal final_left : std_logic;
signal final_right : std_logic;
signal col : std_logic_vector(3 downto 0);	
signal row : std_logic_vector(3 downto 0);	
signal start_row : std_logic_vector(3 downto 0);	
signal start_col : std_logic_vector(3 downto 0);	
signal col_player : std_logic_vector(3 downto 0);		
signal row_player : std_logic_vector(3 downto 0);		
signal up, do, le, ri : std_logic;

begin


start_row <= "0111";
start_col <= "0111";

playerPos(7 downto 4) <= row_player;
playerPos(3 downto 0) <= col_player;

process(clk)
begin
	if rising_edge(clk) then
		signal_up1 <= go_up;
		signal_up2 <= signal_up1;
		signal_up3 <= signal_up2;
	end if;
end process;

-- down 

process(clk)
begin
	if rising_edge(clk) then
		signal_down1 <= go_down;
		signal_down2 <= signal_down1;
		signal_down3 <= signal_down2;
	end if;
end process;


-- left 

process(clk)
begin
	if rising_edge(clk) then
		signal_left1 <= go_left;
		signal_left2 <= signal_left1;
		signal_left3 <= signal_left2;
	end if;
end process;

-- right

process(clk)
begin
	if rising_edge(clk) then
		signal_right1 <= go_right;
		signal_right2 <= signal_right1;
		signal_right3 <= signal_right2;
	end if;
end process;

final_up <= (signal_up3 and (not signal_up2));
final_down <= (signal_down3 and (not signal_down2));
final_left <= (signal_left3 and (not signal_left2));
final_right <= (signal_right3 and (not signal_right2));


-- fsm

process(clk, rst,fsm_state, start_row, start_col)
begin
	if rst = '0' then
		fsm_state <= A;
		row_player <= start_row;
		col_player <= start_col;
	elsif rising_edge(clk)then
		case fsm_state is

		when A =>
			if final_up = '1'then
				if not(row_player = 0) then 
					row <= row_player - 1;
					col <= col_player;
				end if;
				fsm_state <= B;
			elsif final_down = '1' then
				row <= row_player + 1;
				col <= col_player;
				fsm_state <= C;
			elsif final_left = '1'then
				row <= row_player;
				col <= col_player - 1;
				fsm_state <= D;
			elsif final_right = '1'then
				row <= row_player;
				col <= col_player + 1;
				fsm_state <= E;
			end if;
		when B =>
			if row >= 0 then
				row_player <= row;
				fsm_state <= A;
			else 
				fsm_state <= A;
			end if;
		when C =>
			if row < 12 then
				row_player <= row_player + 1;
				fsm_state <= A;
			else
				fsm_state <= A;
			end if;
		when D =>
			if col > 1 then
				col_player <= col_player - 1;
				fsm_state <= A;
			else 
				fsm_state <= A;
			end if;
		when E =>
			if col <= 13 then
				col_player <= col_player + 1;
				fsm_state <= A;
			else
				fsm_state <= A;
			end if;
		when others =>
			fsm_state <= A;
		end case;
	end if;
end process;
end RTL;