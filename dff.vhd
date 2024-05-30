LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY dff IS
	PORT (
			clk, D : IN std_logic;
			Q : OUT std_logic
);
END dff;
ARCHITECTURE d of dff IS
	
BEGIN
	L1 : PROCESS(clk,D)
	BEGIN
	IF(rising_edge(clk)) THEN
		Q <= D;
	END IF;
	END PROCESS;
END d;
