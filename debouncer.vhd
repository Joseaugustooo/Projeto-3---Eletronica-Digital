LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY debouncer IS
	PORT (
			clock : IN std_logic;
			deb : IN std_logic;
			q : OUT std_logic
);
END debouncer;
ARCHITECTURE db of debouncer IS
	CONSTANT overflow : integer := 1500000;
	SIGNAL dff : std_logic_vector(1 DOWNTO 0);
	SIGNAL aux : std_logic;
	SIGNAL cnt : integer:= 0;
	SIGNAL s : std_logic := '0';
	SIGNAL reg : std_logic := '1';
BEGIN 	
	dff(0) <= deb;
	dff(1) <= dff(0);
	aux <= dff(1) xor dff(0);
	L1 : process(clock,deb,s)
	BEGIN
		IF(aux = '1') THEN
			cnt <= 0;
		ELSE
			IF(rising_edge(clock)) THEN
				IF(cnt < overflow)  THEN 
					cnt <= cnt+1;
					s <= '0';
				ELSE 
					cnt <=0;
					s <= '1';
				END IF;
			END IF;
		END IF;
		IF(s = '1') THEN
			q <= deb;
			reg <= deb;
		ELSE
			q <= reg;
		END IF;
	END PROCESS;
END db;
		
			
		
