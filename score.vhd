library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all; -- include package stdio.vhd
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;

entity score is 
port (
	clk : in std_logic;
   score1 : in std_logic_vector(3 downto 0);
   score10 : in std_logic_vector(3 downto 0);   
	hex00 : out std_logic;
	hex01 : out std_logic;
	hex02 : out std_logic;
	hex03 : out std_logic;
	hex04 : out std_logic;
	hex05 : out std_logic;
	hex06 : out std_logic;
	hex10 : out std_logic;
	hex11 : out std_logic;
	hex12 : out std_logic;
	hex13 : out std_logic;
	hex14 : out std_logic;
	hex15 : out std_logic;
	hex16 : out std_logic
);
end score;

architecture bhv of score is 
shared variable temp_hex00 : std_logic := '1';
shared variable temp_hex01 : std_logic := '1';
shared variable temp_hex02 : std_logic := '1';
shared variable temp_hex03 : std_logic := '1';
shared variable temp_hex04 : std_logic := '1';
shared variable temp_hex05 : std_logic := '1';
shared variable temp_hex06 : std_logic := '0';
shared variable temp_hex10 : std_logic := '1';
shared variable temp_hex11 : std_logic := '1';
shared variable temp_hex12 : std_logic := '1';
shared variable temp_hex13 : std_logic := '1';
shared variable temp_hex14 : std_logic := '1';
shared variable temp_hex15 : std_logic := '1';
shared variable temp_hex16 : std_logic := '0';
begin
hex00 <= temp_hex00;
hex01 <= temp_hex01;
hex02 <= temp_hex02;
hex03 <= temp_hex03;
hex04 <= temp_hex04;
hex05 <= temp_hex05;
hex06 <= temp_hex06;

hex10 <= temp_hex10;
hex11 <= temp_hex11;
hex12 <= temp_hex12;
hex13 <= temp_hex13;
hex14 <= temp_hex14;
hex15 <= temp_hex15;
hex16 <= temp_hex16;

drive_hex_0 : process(clk)
variable num : integer;
begin
if rising_edge(clk) then
    if (score1 = 0) then 
    	temp_hex00 := '0';
		temp_hex01 := '0';
		temp_hex02 := '0';
		temp_hex03 := '0';
		temp_hex04 := '0';
		temp_hex05 := '0';
		temp_hex06 := '0';
	elsif (score1 = 1) then 
		temp_hex00 := '1';
		temp_hex01 := '0';
		temp_hex02 := '0';
		temp_hex03 := '1';
		temp_hex04 := '1';
		temp_hex05 := '1';
		temp_hex06 := '1';
	elsif (score1 = 2) then
		temp_hex00 := '0';
		temp_hex01 := '0'; 
		temp_hex02 := '1';
		temp_hex03 := '0';
		temp_hex04 := '0';
		temp_hex05 := '1';
		temp_hex06 := '0';	
	elsif (score1 = 3) then
		temp_hex00 := '0';
		temp_hex01 := '0'; 
		temp_hex02 := '0';
		temp_hex03 := '0';
		temp_hex04 := '1';
		temp_hex05 := '1';
		temp_hex06 := '0';
	elsif (score1 = 4) then
		temp_hex00 := '1';
		temp_hex01 := '0'; 
		temp_hex02 := '0';
		temp_hex03 := '1';
		temp_hex04 := '1';
		temp_hex05 := '0';
		temp_hex06 := '0';
	elsif (score1 = 5) then
		temp_hex00 := '0';
		temp_hex01 := '1'; 
		temp_hex02 := '0';
		temp_hex03 := '0';
		temp_hex04 := '1';
		temp_hex05 := '0';
		temp_hex06 := '0';
	elsif (score1 = 6) then
		temp_hex00 := '0';
		temp_hex01 := '1'; 
		temp_hex02 := '0';
		temp_hex03 := '0';
		temp_hex04 := '0';
		temp_hex05 := '0';
		temp_hex06 := '0';
	elsif (score1 = 7) then
		temp_hex00 := '0';
		temp_hex01 := '0'; 
		temp_hex02 := '0';
		temp_hex03 := '1';
		temp_hex04 := '1';
		temp_hex05 := '1';
		temp_hex06 := '1';
	elsif (score1 = 8) then
		temp_hex00 := '0';
		temp_hex01 := '0'; 
		temp_hex02 := '0';
		temp_hex03 := '0';
		temp_hex04 := '0';
		temp_hex05 := '0';
		temp_hex06 := '0';
	elsif (score1 = 9) then
		temp_hex00 := '0';
		temp_hex01 := '0'; 
		temp_hex02 := '0';
		temp_hex03 := '1';
		temp_hex04 := '1';
		temp_hex05 := '0';
		temp_hex06 := '0';
	else
		temp_hex00 := '1';
		temp_hex01 := '1'; 
		temp_hex02 := '1';
		temp_hex03 := '1';
		temp_hex04 := '1';
		temp_hex05 := '1';
		temp_hex06 := '0';
	end if;
end if;
end process;

drive_hex_1 : process(clk)
variable num : integer;
begin
if rising_edge(clk) then 
	if (score10 = 0) then 
		temp_hex10 := '0';
		temp_hex11 := '0';
		temp_hex12 := '0';
		temp_hex13 := '0';
		temp_hex14 := '0';
		temp_hex15 := '0';
		temp_hex16 := '1';
	elsif (score10 = 1) then 
		temp_hex10 := '1';
		temp_hex11 := '0';
		temp_hex12 := '0';
		temp_hex13 := '1';
		temp_hex14 := '1';
		temp_hex15 := '1';
		temp_hex16 := '1';
	elsif (score10 = 2) then
		temp_hex10 := '0';
		temp_hex11 := '0';
		temp_hex12 := '1';
		temp_hex13 := '0';
		temp_hex14 := '0';
		temp_hex15 := '1';
		temp_hex16 := '0';
	elsif (score10 = 3) then
		temp_hex10 := '0';
		temp_hex11 := '0';
		temp_hex12 := '0';
		temp_hex13 := '0';
		temp_hex14 := '1';
		temp_hex15 := '1';
		temp_hex16 := '0';
	elsif (score10 = 4) then
		temp_hex10 := '1';
		temp_hex11 := '0';
		temp_hex12 := '0';
		temp_hex13 := '1';
		temp_hex14 := '1';
		temp_hex15 := '0';
		temp_hex16 := '0';
	elsif (score10 = 5) then
		temp_hex10 := '0';
		temp_hex11 := '1';
		temp_hex12 := '0';
		temp_hex13 := '0';
		temp_hex14 := '1';
		temp_hex15 := '0';
		temp_hex16 := '0';
	elsif (score10 = 6) then
		temp_hex10 := '0';
		temp_hex11 := '1';
		temp_hex12 := '0';
		temp_hex13 := '0';
		temp_hex14 := '0';
		temp_hex15 := '0';
		temp_hex16 := '0';
	elsif (score10 = 7) then
		temp_hex10 := '0';
		temp_hex11 := '0';
		temp_hex12 := '0';
		temp_hex13 := '1';
		temp_hex14 := '1';
		temp_hex15 := '1';
		temp_hex16 := '1';
	elsif (score10 = 8) then
		temp_hex10 := '0';
		temp_hex11 := '0';
		temp_hex12 := '0';
		temp_hex13 := '0';
		temp_hex14 := '0';
		temp_hex15 := '0';
		temp_hex16 := '0';
	elsif (score10 = 9) then
		temp_hex10 := '0';
		temp_hex11 := '0';
		temp_hex12 := '0';
		temp_hex13 := '1';
		temp_hex14 := '1';
		temp_hex15 := '0';
		temp_hex16 := '0';
	else
		temp_hex10 := '1';
		temp_hex11 := '1';
		temp_hex12 := '1';
		temp_hex13 := '1';
		temp_hex14 := '1';
		temp_hex15 := '1';
		temp_hex16 := '0';
	end if;
end if;
end process;
end bhv;
