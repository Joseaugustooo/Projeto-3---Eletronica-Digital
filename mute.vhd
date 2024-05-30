LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mute IS
	PORT (
			clk : IN std_logic;
			pulso : IN std_logic;
			q : OUT std_logic
);
END mute;

ARCHITECTURE m of mute IS
BEGIN
	q <= pulso and clk;
END m;
	