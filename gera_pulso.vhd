-- Arquivo: gera_pulso.vhd
-- Descrição: Lê botão e gera um pulso
-- Autor: Malki-çedheq Benjamim
-- Data: 04/02/2022
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY gera_pulso IS
	PORT (clk, pushbutton : IN std_logic;
			pulso : OUT std_logic);
END gera_pulso ;

ARCHITECTURE BHV OF gera_pulso IS
SIGNAL q1, q2 : std_logic;
BEGIN
	PROCESS (clk, q1, q2)
	BEGIN
		IF rising_edge(clk) THEN
			q1 <= pushbutton;
			q2 <= q1;
		END IF ;
		pulso <= (NOT q1) NOR q2;
	END PROCESS;
END BHV ;