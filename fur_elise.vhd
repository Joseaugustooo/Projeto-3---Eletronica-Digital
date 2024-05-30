LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.pkg_buzzer_fur_elise.ALL;
ENTITY fur_elise IS
	PORT (clock, stop, play, sel : IN std_logic;
			buzzer: OUT std_logic);		
END fur_elise;
ARCHITECTURE estrutural OF fur_elise IS
	SIGNAL t1, t2, t4 : std_logic;
	SIGNAL t3, t5 : std_logic_vector (27 DOWNTO 0);
	SIGNAL play_p : std_logic;
	SIGNAL stop_p : std_logic;
	SIGNAL t : std_logic := '0';
	SIGNAL tt : std_logic;
BEGIN
	temp : temporizador PORT MAP ( 
		Clk => clock,
		Disparo =>t2,
		Overflow =>	t3,
		Q => t1
	);
		
	div_clock : divisor_clock PORT MAP (
		Clk_in 	=> clock,
		Overflow => t5,
		Clk_out	=> buzzer
	);
	
	control : controlador_fur_elise PORT MAP ( 	
		Clk_out  => t4,
		Disparo  => t2,
		Temp_out => t3,
		Freq_out => t5,
		Clk_in  => clock,
		Stop_in => stop_p,
		Play_in => t,
		Duracao => t1
	);
	p : gera_pulso PORT MAP(
		clk => clock,
		pushbutton => NOT(play),
		pulso => play_p
	);
	s : gera_pulso PORT MAP(
		clk => clock,
		pushbutton => NOT(stop),
		pulso => stop_p
	);
	PROCESS(clock)
	BEGIN
		IF (RISING_EDGE(tt)) THEN
			t <= NOT(t);
		END IF;
		IF (sel = '1') THEN
			IF (t = '1') THEN
				tt <= stop_p OR play_p;
			ELSE tt <= play_p;
			END IF;
		END IF;
	END PROCESS;
END estrutural;
