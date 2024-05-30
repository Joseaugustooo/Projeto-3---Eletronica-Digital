LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY divisor_clock_des IS
	PORT (Clk_in 	: IN std_logic;
			Overflow : IN integer;
			Clk_out	: OUT std_logic := '0');		
END divisor_clock_des;

ARCHITECTURE clock OF divisor_clock_des IS
	SIGNAL estouro : std_logic := '0';
	SIGNAL cnt : integer := 0;
BEGIN
	PROCESS(Clk_in)
	BEGIN
		IF rising_edge(Clk_in) THEN
			IF cnt < (Overflow) THEN
				cnt <= cnt + 1; --incrementa
				estouro <= '0';
			ELSE
				cnt <= 0; --reinicia
				estouro <= '1'; 						
			END IF;
		END IF;
	END PROCESS;	
	Clk_out <= estouro;
END clock;