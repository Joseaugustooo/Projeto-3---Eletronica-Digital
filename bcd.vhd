LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY bcd IS
	PORT (
			bcd : IN INTEGER RANGE 0 TO 15;
			lt, bi, rbi: IN BIT;
			seg: OUT BIT_VECTOR(0 TO 6);
			dp, rbo : OUT BIT);
END bcd;
ARCHITECTURE displaySegmento OF bcd IS
BEGIN 
	PROCESS (bcd, lt, bi, rbi)
		VARIABLE seg_v : BIT_VECTOR(0 TO 6);
		VARIABLE rbo_v : BIT;
	BEGIN 
		IF bi = '0' THEN
			seg_v := "1111111";
			rbo_v := '0';
		ELSIF lt = '0' THEN 
			seg_v := "0000000";
			rbo_v := '1';
		ELSIF (rbi = '0' AND bcd = 0) THEN 
			seg_v := "1111111";
			rbo_v := '0';
		ELSE
			CASE bcd IS 
				WHEN 0 => seg_v := b"0_0_0_0_0_0_1";
				WHEN 1 => seg_v := b"1_0_0_1_1_1_1";
				WHEN 2 => seg_v := b"0_0_1_0_0_1_0";
				WHEN 3 => seg_v := b"0_0_0_0_1_1_0";
				WHEN 4 => seg_v := b"1_0_0_1_1_0_0";
				WHEN 5 => seg_v := b"0_1_0_0_1_0_0";
				WHEN 6 => seg_v := b"1_1_0_0_0_0_0";
				WHEN 7 => seg_v := b"0_0_0_1_1_1_1";
				WHEN 8 => seg_v := b"0_0_0_0_0_0_0";
				WHEN 9 => seg_v := b"0_0_0_0_0_0_1";
				WHEN OTHERS => seg_v := b"1_1_1_1_1_1_1";
			END CASE;
			rbo_v := '1';
		END IF;
		seg(0) <= seg_v(0);
		seg(1) <= seg_v(1);
		seg(2) <= seg_v(2);
		seg(3) <= seg_v(3);
		seg(4) <= seg_v(4);
		seg(5) <= seg_v(5);
		seg(6) <= seg_v(6);
		dp <= '0';
		rbo <= rbo_v;
	END PROCESS;
END displaySegmento;
		
		