library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ps2_keyboard is
port
(	clk          : in  std_logic;  -- System Clock	
	rst		  	: in  std_logic;                    
   ps2_clk      : in  std_logic;  -- Keyboard clock                
   ps2_data     : in  std_logic;                     
   go_up			: out std_logic;
   go_down 		: out std_logic;
   go_left 		: out std_logic;
   go_right 		:out std_logic;
   sel			: out std_logic;
   valid     : out std_logic      -- Data received correctly
);    
end ps2_keyboard;


architecture bhv of  ps2_keyboard is
	signal data : std_logic_vector(10 downto 0);
	signal edge_detect : std_logic_vector(2 downto 0);
	signal reset, internal_reset, error_check, parity, enable, correct, got_new, rising, falling : std_logic;
	signal lock_up, lock_down, lock_left, lock_right, lock_sel, data_valid : integer;
	signal counter : std_logic_vector(3 downto 0);
	signal key : std_logic_vector(2 downto 0);
begin

go_up <= '1' when key = "000" else '0';
go_down <= '1' when key = "001" else '0';
go_left <= '1' when key = "010" else '0';
go_right <= '1' when key = "011" else '0';
sel <= '1' when key = "100" else '0';

valid <= got_new;

parity <=  data(9) xor data(8) xor data(7) xor data(6) xor data(5) xor data(4) xor data(3) xor data(2) xor data(1); --must return 1
error_check <= not(parity and not(data(0)) and data(10));
reset <= '0' when (rst = '0' or internal_reset = '0') else '1';

-- Detect rising and falling edge of keyboard's clock.
process(clk)
begin 
	if rising_edge(clk) then 
		edge_detect(2) <= edge_detect(1);
		edge_detect(1) <= edge_detect(0);
		edge_detect(0) <= ps2_clk;			
		correct <= '0';
	end if;
end process;

rising <= edge_detect(2) and not(edge_detect(1));
falling <= edge_detect(1) and not(edge_detect(2));

process(clk)
begin
if (rising_edge(clk)) then
	if reset = '0' then
		counter<=(others => '0');
		enable <= '0';
		correct <= '0';
		data <= (others => '0');

	else
		if rising = '1' and enable = '0' then
			enable <= '1';
		end if;
		if falling = '1' and enable = '1' then
		-- Gets an 11 bit vector of data from the keyboard 
			data(to_integer(unsigned(counter))) <= ps2_data;
			counter <= counter + 1;
			if counter=10 then
				counter<= (others => '0');
				enable <= '0';
				if error_check = '0' then
					correct <= '1';
				end if;
			end if;
		end if;
	end if;

end if;
end process;


process(clk)
begin
if (rising_edge(clk)) then
	if reset='0' then
	   internal_reset <= '1';
		got_new <= '0';
	elsif  error_check = '0' and enable = '0' and correct <= '1' then
		got_new <= '1';
	-- FSM that tries to avoid duplicate keycodes on button release.
		case data(8 downto 1) is
			when "00011101" => 
				case lock_up is 
					when 0 =>
						key <= "000";
					when 1 =>
						lock_up <= 2;
					when 2 =>
						lock_up <= 0;
						lock_down <= 0;
						lock_left <= 0;
						lock_right <= 0;
						lock_sel <= 0;
					when others =>
					end case;
			when "00011011" => 
				case lock_down is 
					when 0 =>
						key <= "001";
					when 1 =>
						lock_down <= 2;
					when 2 =>
						lock_up <= 0;
						lock_down <= 0;
						lock_left <= 0;
						lock_right <= 0;
						lock_sel <= 0;
					when others =>
					end case;
			when "00011100" => 
				case lock_left is 
					when 0 =>
						key <= "010";
					when 1 =>
						lock_left <= 2;
					when 2 =>
						lock_up <= 0;
						lock_down <= 0;
						lock_left <= 0;
						lock_right <= 0;
						lock_sel <= 0;
					when others =>
					end case;
			when "00100011" => 
					case lock_right is 
					when 0 =>
						key <= "011";
					when 1 =>
						lock_right <= 2;
					when 2 =>
						lock_up <= 0;
						lock_down <= 0;
						lock_left <= 0;
						lock_right <= 0;
						lock_sel <= 0;
					when others =>
					end case;
			when "00101001" =>
				case lock_sel is 
					when 0 =>
						key <= "100";
					when 1 =>
						lock_sel <= 2;
					when 2 =>
						lock_up <= 0;
						lock_down <= 0;
						lock_left <= 0;
						lock_right <= 0;
						lock_sel <= 0;
					when others =>
					end case;
			when "11110000" =>
				lock_up <= 1;
				lock_down <= 1;
				lock_left <= 1;
				lock_right <= 1;
				lock_sel <= 1;
				key <= "111";
			when others	=> key <= "111";
			end case;		
	end if;
	if got_new = '1' then
		internal_reset <= '0';
	end if;
end if;
end process;
end architecture ; 

