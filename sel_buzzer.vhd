LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY sel_buzzer IS
	PORT (	q : IN std_logic_vector(7 DOWNTO 1);
				clk,m1,m2,m3,m4,m5,m6,m7 : IN std_logic;
				b : OUT std_logic
);
END sel_buzzer;

ARCHITECTURE s OF sel_buzzer IS

BEGIN
	PROCESS(clk)
	BEGIN
		CASE (q) IS
			WHEN B"0000001" => b <= m1;
			WHEN B"0000010" => b <= m2;
			WHEN B"0000100" => b <= m3;
			WHEN B"0001000" => b <= m4;
			WHEN B"0010000" => b <= m5;
			WHEN B"0100000" => b <= m6;
			WHEN B"1000000" => b <= m7;
			WHEN OTHERS => b <= '0';
		END CASE;
	END PROCESS;
	
END s;