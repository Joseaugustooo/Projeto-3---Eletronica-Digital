LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mux IS
	PORT (	clk, seletor,play,stop: IN std_logic;
				q : OUT std_logic_vector(7 DOWNTO 1)
);
END mux;
ARCHITECTURE m OF mux IS
	COMPONENT gera_pulso
		PORT ( clk, pushbutton : IN std_logic;
				 pulso : OUT std_logic);
	END COMPONENT;
	SIGNAL d : std_logic_vector(7 DOWNTO 1):= B"0000001";
	SIGNAL p_out : std_logic;
	SIGNAL t: std_logic:='0';
	SIGNAL tt : std_logic;
	SIGNAL pl : std_logic;
	SIGNAL sl : std_logic;
BEGIN
	p : gera_pulso PORT MAP (clk,NOT(seletor),p_out);
	play_p : gera_pulso PORT MAP (clk,NOT(play),pl);
	stop_p : gera_pulso PORT MAP (clk,NOT(stop),sl);
	PROCESS(clk)
	BEGIN
		IF (t = '0') THEN tt <= pl;
		ELSE tt <= sl;
		END IF;
		IF (rising_edge(tt)) THEN
			t <= not(t);
		END IF;
		IF (t = '0') THEN
			IF (rising_edge(p_out)) THEN
				d(1) <= d(7);
				d(2) <= d(1);
				d(3) <= d(2);
				d(4) <= d(3);
				d(5) <= d(4);
				d(6) <= d(5);
				d(7) <= d(6);
			END IF;
		END IF;
	END PROCESS;
	q <= d;
END m;