LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY registrador_de_deslocamento IS
	PORT (	clk,play,stop : IN std_logic;
				q : OUT std_logic_vector(4 DOWNTO 1);
				ponto : OUT std_logic;
				bcd : OUT integer RANGE 0 TO 15
);
END registrador_de_deslocamento;
ARCHITECTURE rd OF registrador_de_deslocamento IS
	COMPONENT gera_pulso
		PORT ( clk, pushbutton : IN std_logic;
				 pulso : OUT std_logic);
	END COMPONENT;
	
	COMPONENT divisor_clock_des
		PORT (Clk_in 	: IN std_logic;
				Overflow : IN integer;
				Clk_out	: OUT std_logic := '0');
		END COMPONENT;
	SIGNAL d : std_logic_vector(4 DOWNTO 1):= B"0001";
	SIGNAL p_out : std_logic;
	SIGNAL c : std_logic;
	SIGNAL p : std_logic;
	CONSTANT ovd : integer := 100000;
	CONSTANT ovc : integer := 5000000;
	SIGNAL dec : integer RANGE 0 TO 15 :=0;
	SIGNAL useg : integer RANGE 0 TO 15 :=0;
	SIGNAL dseg : integer RANGE 0 TO 15 :=0;
	SIGNAL min : integer RANGE 0 TO 15 :=0;
	SIGNAL t : std_logic :='0';
	SIGNAL tt : std_logic :='0';
	SIGNAL pl : std_logic;
	SIGNAL sl : std_logic;
BEGIN
	div : divisor_clock_des PORT MAP (clk,ovd,p_out);
	cont : divisor_clock_des PORT MAP (clk,ovc,c);
	play_p : gera_pulso PORT MAP (clk,NOT(play),pl);
	stop_p : gera_pulso PORT MAP (clk,NOT(stop),sl);
	L1: PROCESS(clk)
	BEGIN
		IF (rising_edge(p_out)) THEN
			d(1) <= d(4);
			d(2) <= d(1);
			d(3) <= d(2);
			d(4) <= d(3);
		END IF;
	END PROCESS;
	L2: PROCESS(d)
	BEGIN
		CASE(d) IS
			WHEN B"0001" => bcd <= dec; p <= '1';
			WHEN B"0010" => bcd <= useg;p <= '0';
			WHEN B"0100" => bcd <= dseg;p <= '1';
			WHEN B"1000" => bcd <= min;p <= '0';
			WHEN OTHERS => bcd <= 0;p <= '0';
		END CASE;
	END PROCESS;
	L3: PROCESS(clk)
	BEGIN
		IF (sl = '1') THEN
			dec <= 0;
			useg <= 0;
			dseg <= 0;
			min <= 0;
		ELSIF (t = '1') THEN
			IF (rising_edge(c)) THEN
				IF (dec <9 AND useg < 10 AND dseg < 6 AND min < 9) THEN
					dec <= dec+1;
					useg <= useg;
					dseg <= dseg;
					min <= min;
				ELSIF (dec >= 9 AND useg < 9 AND dseg < 6 AND min < 9) THEN
					dec <= 0;
					useg <= useg+1;
					dseg <= dseg;
					min <= min;
				ELSIF (dec >= 9 AND useg >= 9 AND dseg < 5 AND min < 9) THEN
					dec <= 0;
					useg <= 0;
					dseg <= dseg+1;
					min <= min;
				ELSIF (dec >= 9 AND useg >= 9 AND dseg >= 5 AND min < 9) THEN
					dec <= 0;
					useg <= 0;
					dseg <= 0;
					min <= min +1;
				ELSE 
					dec <= dec;
					useg <= useg;
					dseg <= dseg;
					min <= min;
				END IF;
			END IF;
		END IF;
		IF (rising_edge(tt)) THEN
			t <= NOT(t);
		END IF;
	END PROCESS;
	L4: PROCESS(clk)
	BEGIN
		IF (t = '1') THEN tt <= pl OR sl;
		ELSE	tt <= pl;
		END IF;
	END PROCESS;
	L5: PROCESS(clk)
	BEGIN
		
	END PROCESS;
	q <= NOT(d);
	ponto <= p;
END rd;