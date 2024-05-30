LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY controlador_harry_potter IS
PORT ( 	Clk_out, Disparo  : OUT std_logic := '0';
			Temp_out, Freq_out : OUT std_logic_vector (27 DOWNTO 0);	
			Clk_in, Duracao, Stop_in, Play_in : IN std_logic
		);
END controlador_harry_potter;
ARCHITECTURE bhv OF controlador_harry_potter IS
  -- Subprograma para aplicar o tempo e frequencia na saída dos estados
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
	CONSTANT	CS3 : integer := 90090; --555Hz
	CONSTANT D3 : integer := 85034; --588Hz
	CONSTANT F3 : integer := 71530; --699Hz
	CONSTANT G3 : integer := 63776; --784Hz
	CONSTANT GS3 : integer := 60169; --831Hz
	CONSTANT A3 : integer := 56819; --880Hz
	CONSTANT AS3 : integer := 53591; --933Hz
	CONSTANT B3 : integer := 50608; --988Hz
	CONSTANT C4 : integer := 47756; --1047Hz
	CONSTANT CS4 : integer := 45085; --1110Hz
	CONSTANT D4 : integer := 42554; --1175Hz
	CONSTANT DS4 : integer := 40161; --1245Hz
	CONSTANT E4 : integer := 37908; --1319Hz
	CONSTANT F4 : integer := 35790; --1397Hz
		
	--overflow para tempos (50MHz)
	-- BPM igual a 60 implica que t1, 1 batida, representa 1 seg
	CONSTANT BPM : integer := 190; --batidas por minuto
	CONSTANT BPS : integer := BPM / 60; --batidas por segundo
	CONSTANT ov_t6 : integer := ((6 * clk_FPGA)) / BPS; --overflow 6 batidas
	CONSTANT ov_t3 : integer := ((3 * clk_FPGA)) / BPS; --overflow 3 batidas
	CONSTANT ov_t2 : integer := (2 * clk_FPGA) / BPS; --overflow 2 batidas
	CONSTANT ov_t1 : integer := clk_FPGA / BPS; --overflow 1 batida
	CONSTANT ov_t1_2 : integer := (clk_FPGA / 2) / BPS; --overflow 1/2 batidas
	CONSTANT ov_t3_2 : integer := (((3 / 2) * clk_FPGA)) / BPS; --overflow 3/2 batidas
		
	--FSM Declaração de estados 
	TYPE estados IS (s0, s1 , s2, s3, s4, s5, s6, s7, s8, s9, s10, 
						s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
						s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, 
						s31, s32, s33, s34, s35, s36, s37, s38, s39, s40, 
						s41, s42, s43, s44, s45, s46, s47, s48, s49, s50,
						s51, s52, s53, s54, s55, s56, s57, s58, s59, s60,
						s61, s62);
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
						proximo_estado <= s14;					
					ELSE proximo_estado <= s13;
					END IF;	
				END IF;
			WHEN s14 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s15;					
					ELSE proximo_estado <= s14;
					END IF;	
				END IF;
			WHEN s15 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s16;					
					ELSE proximo_estado <= s15;
					END IF;	
				END IF;
			WHEN s16 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s17;					
					ELSE proximo_estado <= s16;
					END IF;	
				END IF;
			WHEN s17 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s18;					
					ELSE proximo_estado <= s17;
					END IF;	
				END IF;
			WHEN s18 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s19;					
					ELSE proximo_estado <= s18;
					END IF;	
				END IF;
			WHEN s19 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s20;					
					ELSE proximo_estado <= s19;
					END IF;	
				END IF;
			WHEN s20 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s21;					
					ELSE proximo_estado <= s20;
					END IF;	
				END IF;
			WHEN s21 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s22;					
					ELSE proximo_estado <= s21;
					END IF;	
				END IF;
			WHEN s22 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s23;					
					ELSE proximo_estado <= s22;
					END IF;	
				END IF;
			WHEN s23 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s24;					
					ELSE proximo_estado <= s23;
					END IF;	
				END IF;
			WHEN s24 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s25;					
					ELSE proximo_estado <= s24;
					END IF;	
				END IF;
			WHEN s25 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s26;					
					ELSE proximo_estado <= s25;
					END IF;	
				END IF;
			WHEN s26 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s27;					
					ELSE proximo_estado <= s26;
					END IF;	
				END IF;
			WHEN s27 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s28;					
					ELSE proximo_estado <= s27;
					END IF;	
				END IF;
			WHEN s28 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s29;					
					ELSE proximo_estado <= s28;
					END IF;	
				END IF;
			WHEN s29 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s30;					
					ELSE proximo_estado <= s29;
					END IF;	
				END IF;
			WHEN s30 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s31;					
					ELSE proximo_estado <= s30;
					END IF;	
				END IF;
			WHEN s31 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s32;					
					ELSE proximo_estado <= s31;
					END IF;	
				END IF;
			WHEN s32 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s33;					
					ELSE proximo_estado <= s32;
					END IF;	
				END IF;
			WHEN s33 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s34;					
					ELSE proximo_estado <= s33;
					END IF;	
				END IF;
			WHEN s34 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s35;					
					ELSE proximo_estado <= s34;
					END IF;	
				END IF;
			WHEN s35 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s36;					
					ELSE proximo_estado <= s35;
					END IF;	
				END IF;
			WHEN s36 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s37;					
					ELSE proximo_estado <= s36;
					END IF;	
				END IF;
			WHEN s37 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s38;					
					ELSE proximo_estado <= s37;
					END IF;	
				END IF;
			WHEN s38 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s39;					
					ELSE proximo_estado <= s38;
					END IF;	
				END IF;
			WHEN s39 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s40;					
					ELSE proximo_estado <= s39;
					END IF;	
				END IF;
			WHEN s40 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s41;					
					ELSE proximo_estado <= s40;
					END IF;	
				END IF;
			WHEN s41 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s42;					
					ELSE proximo_estado <= s41;
					END IF;	
				END IF;
			WHEN s42 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s43;					
					ELSE proximo_estado <= s42;
					END IF;	
				END IF;
			WHEN s43 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s44;					
					ELSE proximo_estado <= s43;
					END IF;	
				END IF;
			WHEN s44 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s45;					
					ELSE proximo_estado <= s44;
					END IF;	
				END IF;
			WHEN s45 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s46;					
					ELSE proximo_estado <= s45;
					END IF;	
				END IF;
			WHEN s46 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s47;					
					ELSE proximo_estado <= s46;
					END IF;	
				END IF;
			WHEN s47 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s48;					
					ELSE proximo_estado <= s47;
					END IF;	
				END IF;
			WHEN s48 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s49;					
					ELSE proximo_estado <= s48;
					END IF;	
				END IF;
			WHEN s49 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s50;					
					ELSE proximo_estado <= s49;
					END IF;	
				END IF;
			WHEN s50 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s51;					
					ELSE proximo_estado <= s50;
					END IF;	
				END IF;
			WHEN s51 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s52;					
					ELSE proximo_estado <= s51;
					END IF;	
				END IF;
			WHEN s52 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s53;					
					ELSE proximo_estado <= s52;
					END IF;	
				END IF;
			WHEN s53 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s54;					
					ELSE proximo_estado <= s53;
					END IF;	
				END IF;
			WHEN s54 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s55;					
					ELSE proximo_estado <= s54;
					END IF;	
				END IF;
			WHEN s55 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s56;					
					ELSE proximo_estado <= s55;
					END IF;	
				END IF;
			WHEN s56 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s57;					
					ELSE proximo_estado <= s56;
					END IF;	
				END IF;
			WHEN s57 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s58;					
					ELSE proximo_estado <= s57;
					END IF;	
				END IF;
			WHEN s58 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s59;					
					ELSE proximo_estado <= s58;
					END IF;	
				END IF;
			WHEN s59 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s60;					
					ELSE proximo_estado <= s59;
					END IF;	
				END IF;
			WHEN s60 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s61;					
					ELSE proximo_estado <= s60;
					END IF;	
				END IF;
			WHEN s61 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s62;					
					ELSE proximo_estado <= s61;
					END IF;	
				END IF;
			WHEN s62 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s1;					
					ELSE proximo_estado <= s62;
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
				WHEN s1 => nota(0, ov_t2); 
				WHEN s2 => nota(D3, ov_t1);
				WHEN s3 => nota(G3, ov_t3_2);
				WHEN s4 => nota(AS3, ov_t1_2);
				WHEN s5 => nota(A3, ov_t1);
				WHEN s6 => nota(G3, ov_t2);
				WHEN s7 => nota(D4, ov_t1_2);
				WHEN s8 => nota(C4, ov_t3);
				WHEN s9 => nota(A3, ov_t3);
				WHEN s10 => nota(G3, ov_t3_2);
				WHEN s11 => nota(AS3, ov_t1_2);
				WHEN s12 => nota(A3, ov_t1);
				WHEN s13 => nota(F3, ov_t2);
				WHEN s14 => nota(GS3, ov_t1);
				WHEN s15 => nota(D3, ov_t6);
				WHEN s16 => nota(D3, ov_t1);
				WHEN s17 => nota(G3, ov_t3_2);
				WHEN s18 => nota(AS3, ov_t1_2);
				WHEN s19 => nota(A3, ov_t1);
				WHEN s20 => nota(G3, ov_t2);
				WHEN s21 => nota(D4, ov_t1);
				WHEN s22 => nota(F4, ov_t2);
				WHEN s23 => nota(E4, ov_t1);
				WHEN s24 => nota(DS4, ov_t2);
				WHEN s25 => nota(B3, ov_t1);
				WHEN s26 => nota(DS4, ov_t3_2);
				WHEN s27 => nota(D4, ov_t1_2);
				WHEN s28 => nota(CS4, ov_t1);
				WHEN s29 => nota(CS3, ov_t2);
				WHEN s30 => nota(B3, ov_t1);
				WHEN s31 => nota(G3, ov_t3);
				WHEN s32 => nota(AS3, ov_t1);
				WHEN s33 => nota(D4, ov_t2);
				WHEN s34 => nota(AS3, ov_t1);
				WHEN s35 => nota(D4, ov_t2);
				WHEN s36 => nota(AS3, ov_t1);
				WHEN s37 => nota(DS4, ov_t2);
				WHEN s38 => nota(D4, ov_t1);
				WHEN s39 => nota(CS4, ov_t2);
				WHEN s40 => nota(A3, ov_t1);
				WHEN s41 => nota(AS3, ov_t3_2);
				WHEN s42 => nota(D4, ov_t1_2);
				WHEN s43 => nota(CS4, ov_t1);			
				WHEN s44 => nota(CS3, ov_t2);
				WHEN s45 => nota(D3, ov_t1);
				WHEN s46 => nota(D4, ov_t6);
				WHEN s47 => nota(0, ov_t1);
				WHEN s48 => nota(AS3, ov_t1);
				WHEN s49 => nota(D4, ov_t2);
				WHEN s50 => nota(AS3, ov_t1);
				WHEN s51 => nota(D4, ov_t2);
				WHEN s52 => nota(AS3, ov_t1);
				WHEN s53 => nota(F4, ov_t2);
				WHEN s54 => nota(E4, ov_t1);
				WHEN s55 => nota(DS4, ov_t2);
				WHEN s56 => nota(B3, ov_t1);
				WHEN s57 => nota(DS4, ov_t3_2);
				WHEN s58 => nota(D4, ov_t1_2);
				WHEN s59 => nota(CS4, ov_t1);
				WHEN s60 => nota(CS3, ov_t2);
				WHEN s61 => nota(AS3, ov_t1);
				WHEN s62 => nota(G3, ov_t6);
				
--Não é necessário WHEN OTHERS pois o controle é feito no processo L2
			END CASE;
		END IF;
	END PROCESS L3;
	
	--Atribuição contínua
	Clk_out <= Duracao AND Clk_in;
END bhv;