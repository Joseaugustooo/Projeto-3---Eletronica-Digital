LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY controlador_nokia_tune IS
PORT ( 	Clk_out, Disparo  : OUT std_logic := '0';
			Temp_out, Freq_out : OUT std_logic_vector (27 DOWNTO 0);	
			Clk_in, Duracao, Stop_in, Play_in : IN std_logic
		);
END controlador_nokia_tune;
ARCHITECTURE bhv OF controlador_nokia_tune IS
  -- Subprograma para aplicar o tempo e frequencia na saída do estado
  PROCEDURE nota (CONSTANT ov_f : IN integer;
						CONSTANT ov_t : IN integer ) IS
  BEGIN
		Temp_out <= std_logic_vector(to_unsigned(ov_t,Temp_out'LENGTH)); --define a duração	proxima nota			
		Freq_out <= std_logic_vector(to_unsigned(ov_f,Freq_out'LENGTH)); --define a frequência nota atual
		Disparo <= '1';  --dispara o tempo para a próxima nota	
  END nota;
	--clock da placa
	CONSTANT clk_FPGA : integer := 50000000; --50MHz
	--overflow para frequencias (50MHz)
	CONSTANT Cs4 : integer := 90253; --554Hz
	CONSTANT D4 : integer := 85179; --587Hz
	CONSTANT E4 : integer := 75873; --659Hz
	CONSTANT	Fs4 : integer := 67568; --740Hz
	CONSTANT Gs4 : integer := 60241; --830Hz
	CONSTANT A4 : integer := 56819; --880Hz
	CONSTANT B4 : integer := 50608; --988Hz
	CONSTANT Cs5 : integer := 45086; --1109Hz
	CONSTANT D5 : integer := 42554; --1175Hz
	CONSTANT E5 : integer := 37908; --1319Hz
	
	--overflow para tempos (50MHz)
	-- BPM igual a 60 implica que t1, 1 batida, representa 1 seg
	-- BPM igual a 120 implica que t1, 1 batida, representa 0.5 seg
	CONSTANT BPM : integer := 180; --batidas por minuto
	CONSTANT BPS : integer := BPM / 60; --batidas por segundo
	CONSTANT ov_t2 : integer := (2 * clk_FPGA) / BPS; --overflow 2 batida
	CONSTANT ov_t1 : integer := clk_FPGA / BPS; --overflow 1 batida
	CONSTANT ov_t1_2 : integer := (clk_FPGA / 2) / BPS; --overflow 1/2 batida
	
	--FSM Declaração de estados 
	TYPE estados IS (s0, s1 , s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13);
	SIGNAL estado_atual: estados;
	SIGNAL proximo_estado: estados;
BEGIN
	--Lógica para controle do estado atual
	L1: PROCESS(Clk_in)
	BEGIN
		IF rising_edge(Clk_in) THEN 
			estado_atual <= proximo_estado;
		END IF;
	END PROCESS L1;
	--Lógica para próximo estado
	L2: PROCESS (estado_atual, Duracao)
	BEGIN
		CASE estado_atual IS
			WHEN s0 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s1;
					ELSE proximo_estado <= s0;
					END IF;
				END IF;
			WHEN s1 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s2;
					ELSE proximo_estado <= s1;					
					END IF;
				END IF;	
			WHEN s2 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s3;					
					ELSE proximo_estado <= s2;
					END IF;	
				END IF;
			WHEN s3 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s4;					
					ELSE proximo_estado <= s3;
					END IF;	
				END IF;
			WHEN s4 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s5;					
					ELSE proximo_estado <= s4;
					END IF;	
				END IF;
			WHEN s5 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s6;					
					ELSE proximo_estado <= s5;
					END IF;	
				END IF;
			WHEN s6 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s7;					
					ELSE proximo_estado <= s6;
					END IF;	
				END IF;
			WHEN s7 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s8;					
					ELSE proximo_estado <= s7;
					END IF;	
				END IF;
			WHEN s8 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s9;					
					ELSE proximo_estado <= s8;
					END IF;	
				END IF;
			WHEN s9 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s10;					
					ELSE proximo_estado <= s9;
					END IF;	
				END IF;
			WHEN s10 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s11;					
					ELSE proximo_estado <= s10;
					END IF;	
				END IF;
			WHEN s11 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s12;					
					ELSE proximo_estado <= s11;
					END IF;	
				END IF;
			WHEN s12 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s13;					
					ELSE proximo_estado <= s12;
					END IF;	
				END IF;
			WHEN s13 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s1;					
					ELSE proximo_estado <= s13;
					END IF;	
				END IF;
			WHEN OTHERS =>
				--recupera de estado inválido
				proximo_estado <= s0; --reinicia
		END CASE;
	END PROCESS L2;
	--Lógica para saída da FSM
	L3: PROCESS (Clk_in, estado_atual)
	BEGIN
		IF rising_edge(Clk_in) THEN
			CASE estado_atual IS 
				WHEN s0 => nota(0, ov_t1); --s0 apenas inicia a prox nota
				WHEN s1 => nota(E5, ov_t1_2); 
				WHEN s2 => nota(D5, ov_t1_2);
				WHEN s3 => nota(Fs4, ov_t1);
				WHEN s4 => nota(Gs4, ov_t1);
				WHEN s5 => nota(Cs5, ov_t1_2);
				WHEN s6 => nota(B4, ov_t1_2);
				WHEN s7 => nota(D4, ov_t1);
				WHEN s8 => nota(E4, ov_t1);
				WHEN s9 => nota(B4, ov_t1_2);
				WHEN s10 => nota(A4, ov_t1_2);
				WHEN s11 => nota(Cs4, ov_t1);
				WHEN s12 => nota(E4, ov_t1);
				WHEN s13 => nota(A4, ov_t2);
				
--Não é necessário WHEN OTHERS pois o controle é feito no processo L2
			END CASE;
		END IF;
	END PROCESS L3;
	
	--Atribuição contínua
	Clk_out <= Duracao AND Clk_in;
END bhv;