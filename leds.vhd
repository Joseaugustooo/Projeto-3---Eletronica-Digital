LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY leds IS
	PORT (	clk,play,stop: IN std_logic;
				q : OUT std_logic_vector(4 DOWNTO 1)
);
END leds;

ARCHITECTURE l OF leds IS
	COMPONENT gera_pulso
		PORT ( clk, pushbutton : IN std_logic;
				 pulso : OUT std_logic);
	END COMPONENT;
	SIGNAL d : std_logic_vector(4 DOWNTO 1):= B"0000";
	SIGNAL t : std_logic:='0';
	SIGNAL tt : std_logic;
	SIGNAL pl : std_logic;
	SIGNAL sl : std_logic;
	SIGNAL s : std_logic:='1';
	SIGNAL ss : std_logic;
BEGIN
	play_p : gera_pulso PORT MAP (clk,NOT(play),pl);
	stop_p : gera_pulso PORT MAP (clk,NOT(stop),sl);
	PROCESS(clk)
	BEGIN	
		IF (s = '1' AND t = '0') THEN d <= B"0001";
		ELSIF (t  ='1' AND s = '0') THEN d <= B"0010";
		ELSIF (t = '0' AND s = '0') THEN d <= B"0100";
		ELSE d <= B"1000";
		END IF;
		
		IF (rising_edge(tt)) THEN t <= not(t);
		END IF;
		
		IF (t = '1') THEN tt <= pl or sl;
		ELSE tt <= pl;
		END IF;
		
		IF (rising_edge(ss)) THEN s <= not(s);
		END IF;
		
		IF (s = '1') THEN ss <= pl;
		ELSE ss <= sl;
		END IF;
	END PROCESS;
	q <= NOT(d);
END L;