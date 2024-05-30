LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
PACKAGE pkg_buzzer_over_the_rainbow IS

COMPONENT divisor_clock
	PORT (Clk_in : IN std_logic;
			Overflow : IN std_logic_vector (27 DOWNTO 0);
			Clk_out: OUT std_logic);		
END COMPONENT;

COMPONENT temporizador IS
PORT ( Clk, Disparo :IN std_logic;
		 Overflow : IN std_logic_vector (27 DOWNTO 0);	
		 Q :OUT std_logic );
END COMPONENT;

COMPONENT controlador_over_the_rainbow IS
PORT ( 	Clk_out, Disparo  : OUT std_logic;
			Temp_out, Freq_out : OUT std_logic_vector (27 DOWNTO 0);	
			Clk_in, Duracao, Stop_in, Play_in : IN std_logic
		);
END COMPONENT;

COMPONENT gera_pulso
		PORT ( clk, pushbutton : IN std_logic;
				 pulso : OUT std_logic);
	END COMPONENT;

END PACKAGE;