LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY controlador_mario_theme IS
PORT ( 	Clk_out, Disparo  : OUT std_logic := '0';
			Temp_out, Freq_out : OUT std_logic_vector (27 DOWNTO 0);	
			Clk_in, Duracao, Stop_in, Play_in : IN std_logic
		);
END controlador_mario_theme;
ARCHITECTURE bhv OF controlador_mario_theme IS
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
	CONSTANT C4 : integer := 95557; --523Hz
	CONSTANT E4 : integer := 75843; --659Hz
	CONSTANT F4 : integer := 71586; --698Hz
	CONSTANT G4 : integer := 63776; --784Hz
	CONSTANT GS4 : integer := 60197; --831Hz
	CONSTANT A4 : integer := 56819; --880Hz
	CONSTANT AS4 : integer := 53630; --932Hz
	CONSTANT B4 : integer := 50620; --988Hz
	CONSTANT C5 : integer := 47779; --1046Hz
	CONSTANT D5 : integer := 42566; --1175Hz
	CONSTANT DS5 : integer := 40177; --1244Hz
	CONSTANT E5 : integer := 37922; --1318Hz
	CONSTANT F5 : integer := 35793; --1397Hz
	CONSTANT FS5 : integer := 33785; --1480Hz
	CONSTANT G5 : integer := 31889; --1568Hz
	CONSTANT A5 : integer := 28409; --1760Hz
	
	--overflow para tempos (50MHz)
	-- BPM igual a 60 implica que t1, 1 batida, representa 1 seg
	CONSTANT BPM : integer := 238; --batidas por minuto
	CONSTANT BPS : integer := BPM / 60; --batidas por segundo
	CONSTANT ov_t4 : integer := (4 * clk_FPGA) / BPS; --overflow 4 batidas
	CONSTANT ov_t2 : integer := (2 * clk_FPGA) / BPS; --overflow 2 batidas
	CONSTANT ov_t1 : integer := clk_FPGA / BPS; --overflow 1 batida
	CONSTANT ov_t1_2 : integer := (clk_FPGA / 2) / BPS; --overflow 1/2 batidas
	CONSTANT ov_t3_2 : integer := (3 * (clk_FPGA / 2)) / BPS; --overflow 3/2 batidas
	CONSTANT ov_t3_4 : integer := (3 * (clk_FPGA / 4)) / BPS; --overflow 3/4 batidas
		
	--FSM Declaração de estados 
	TYPE estados IS (s0, s1 , s2, s3, s4, s5, s6, s7, s8, s9, s10, 
						s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
						s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, 
						s31, s32, s33, s34, s35, s36, s37, s38, s39, s40, 
						s41, s42, s43, s44, s45, s46, s47, s48, s49, s50,
						s51, s52, s53, s54, s55, s56, s57, s58, s59, s60,
						s61, s62, s63, s64, s65, s66, s67, s68, s69, s70,
						s71, s72, s73, s74, s75, s76, s77, s78, s79, s80,
						s81, s82, s83, s84, s85, s86, s87, s88, s89, s90,
						s91, s92, s93, s94, s95, s96, s97, s98, s99, s100,
						s101, s102, s103, s104, s105, s106, s107, s108, s109, s110,
						s111, s112, s113, s114, s115, s116, s117, s118, s119, s120,
						s121, s122, s123, s124, s125, s126, s127, s128, s129, s130,
						s131, s132, s133, s134, s135, s136, s137, s138, s139, s140,
						s141, s142, s143, s144, s145, s146, s147, s148, s149, s150,
						s151, s152, s153, s154, s155, s156, s157, s158, s159, s160,
						s161, s162, s163, s164, s165, s166, s167, s168, s169, s170,
						s171, s172, s173, s174, s175, s176, s177, s178, s179, s180,
						s181, s182, s183, s184, s185, s186, s187, s188, s189, s190,
						s191, s192, s193, s194, s195, s196, s197, s198, s199, s200,
						s201, s202, s203, s204, s205, s206, s207, s208, s209, s210,
						s211, s212, s213, s214, s215, s216, s217, s218, s219, s220,
						s221, s222, s223, s224, s225, s226, s227, s228, s229, s230,
						s231, s232, s233, s234, s235, s236, s237, s238, s239, s240,
						s241, s242, s243, s244, s245, s246, s247, s248, s249, s250,
						s251, s252, s253, s254, s255, s256, s257, s258, s259, s260,
						s261, s262, s263, s264, s265, s266, s267, s268, s269, s270,
						s271, s272, s273, s274, s275, s276, s277, s278, s279, s280,
						s281, s282, s283, s284, s285, s286, s287, s288, s289, s290,
						s291, s292, s293, s294, s295, s296, s297, s298, s299, s300,
						s301, s302, s303, s304, s305, s306, s307, s308, s309);
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
						proximo_estado <= s63;					
					ELSE proximo_estado <= s62;
					END IF;	
				END IF;
			WHEN s63 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s64;					
					ELSE proximo_estado <= s63;
					END IF;	
				END IF;
			WHEN s64 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s65;					
					ELSE proximo_estado <= s64;
					END IF;	
				END IF;
			WHEN s65 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s66;					
					ELSE proximo_estado <= s65;
					END IF;	
				END IF;
			WHEN s66 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s67;					
					ELSE proximo_estado <= s66;
					END IF;	
				END IF;
			WHEN s67 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s68;					
					ELSE proximo_estado <= s67;
					END IF;	
				END IF;
			WHEN s68 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s69;					
					ELSE proximo_estado <= s68;
					END IF;	
				END IF;
			WHEN s69 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s70;					
					ELSE proximo_estado <= s69;
					END IF;	
				END IF;
			WHEN s70 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s71;					
					ELSE proximo_estado <= s70;
					END IF;	
				END IF;
			WHEN s71 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s72;					
					ELSE proximo_estado <= s71;
					END IF;	
				END IF;
			WHEN s72 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s73;					
					ELSE proximo_estado <= s72;
					END IF;	
				END IF;
			WHEN s73 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s74;					
					ELSE proximo_estado <= s73;
					END IF;	
				END IF;
			WHEN s74 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s75;					
					ELSE proximo_estado <= s74;
					END IF;	
				END IF;
			WHEN s75 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s76;					
					ELSE proximo_estado <= s75;
					END IF;	
				END IF;
			WHEN s76 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s77;					
					ELSE proximo_estado <= s76;
					END IF;	
				END IF;
			WHEN s77 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s78;					
					ELSE proximo_estado <= s77;
					END IF;	
				END IF;
			WHEN s78 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s79;					
					ELSE proximo_estado <= s78;
					END IF;	
				END IF;
			WHEN s79 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s80;					
					ELSE proximo_estado <= s79;
					END IF;	
				END IF;
			WHEN s80 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s81;					
					ELSE proximo_estado <= s80;
					END IF;	
				END IF;
			WHEN s81 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s82;					
					ELSE proximo_estado <= s81;
					END IF;	
				END IF;
			WHEN s82 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s83;					
					ELSE proximo_estado <= s82;
					END IF;	
				END IF;
			WHEN s83 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s84;					
					ELSE proximo_estado <= s83;
					END IF;	
				END IF;
			WHEN s84 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s85;					
					ELSE proximo_estado <= s84;
					END IF;	
				END IF;
			WHEN s85 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s86;					
					ELSE proximo_estado <= s85;
					END IF;	
				END IF;
			WHEN s86 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s87;					
					ELSE proximo_estado <= s86;
					END IF;	
				END IF;
			WHEN s87 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s88;					
					ELSE proximo_estado <= s87;
					END IF;	
				END IF;
			WHEN s88 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s89;					
					ELSE proximo_estado <= s88;
					END IF;	
				END IF;
			WHEN s89 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s90;					
					ELSE proximo_estado <= s89;
					END IF;	
				END IF;
			WHEN s90 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s91;					
					ELSE proximo_estado <= s90;
					END IF;	
				END IF;
			WHEN s91 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s92;					
					ELSE proximo_estado <= s91;
					END IF;	
				END IF;
			WHEN s92 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s93;					
					ELSE proximo_estado <= s92;
					END IF;	
				END IF;
			WHEN s93 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s94;					
					ELSE proximo_estado <= s93;
					END IF;	
				END IF;
			WHEN s94 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s95;					
					ELSE proximo_estado <= s94;
					END IF;	
				END IF;
			WHEN s95 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s96;					
					ELSE proximo_estado <= s95;
					END IF;	
				END IF;
			WHEN s96 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s97;					
					ELSE proximo_estado <= s96;
					END IF;	
				END IF;
			WHEN s97 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s98;					
					ELSE proximo_estado <= s97;
					END IF;	
				END IF;
			WHEN s98 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s99;					
					ELSE proximo_estado <= s98;
					END IF;	
				END IF;
			WHEN s99 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s100;					
					ELSE proximo_estado <= s99;
					END IF;	
				END IF;
			WHEN s100 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s101;					
					ELSE proximo_estado <= s100;
					END IF;	
				END IF;
			WHEN s101 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s102;					
					ELSE proximo_estado <= s101;
					END IF;	
				END IF;
			WHEN s102 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s103;					
					ELSE proximo_estado <= s102;
					END IF;	
				END IF;
			WHEN s103 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s104;					
					ELSE proximo_estado <= s103;
					END IF;	
				END IF;
			WHEN s104 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s105;					
					ELSE proximo_estado <= s104;
					END IF;	
				END IF;
			WHEN s105 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s106;					
					ELSE proximo_estado <= s105;
					END IF;	
				END IF;
			WHEN s106 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s107;					
					ELSE proximo_estado <= s106;
					END IF;	
				END IF;
			WHEN s107 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s108;					
					ELSE proximo_estado <= s107;
					END IF;	
				END IF;
			WHEN s108 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s109;					
					ELSE proximo_estado <= s108;
					END IF;	
				END IF;
			WHEN s109 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s110;					
					ELSE proximo_estado <= s109;
					END IF;	
				END IF;
			WHEN s110 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s111;					
					ELSE proximo_estado <= s110;
					END IF;	
				END IF;
			WHEN s111 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s112;					
					ELSE proximo_estado <= s111;
					END IF;	
				END IF;
			WHEN s112 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s113;					
					ELSE proximo_estado <= s112;
					END IF;	
				END IF;
			WHEN s113 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s114;					
					ELSE proximo_estado <= s113;
					END IF;	
				END IF;
			WHEN s114 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s115;					
					ELSE proximo_estado <= s114;
					END IF;	
				END IF;
			WHEN s115 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s116;					
					ELSE proximo_estado <= s115;
					END IF;	
				END IF;
			WHEN s116 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s117;					
					ELSE proximo_estado <= s116;
					END IF;	
				END IF;
			WHEN s117 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s118;					
					ELSE proximo_estado <= s117;
					END IF;	
				END IF;
			WHEN s118 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s119;					
					ELSE proximo_estado <= s118;
					END IF;	
				END IF;
			WHEN s119 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s120;					
					ELSE proximo_estado <= s119;
					END IF;	
				END IF;
			WHEN s120 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s121;					
					ELSE proximo_estado <= s120;
					END IF;	
				END IF;
			WHEN s121 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s122;					
					ELSE proximo_estado <= s121;
					END IF;	
				END IF;
			WHEN s122 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s123;					
					ELSE proximo_estado <= s122;
					END IF;	
				END IF;
			WHEN s123 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s124;					
					ELSE proximo_estado <= s123;
					END IF;	
				END IF;
			WHEN s124 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s125;					
					ELSE proximo_estado <= s124;
					END IF;	
				END IF;
			WHEN s125 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s126;					
					ELSE proximo_estado <= s125;
					END IF;	
				END IF;
			WHEN s126 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s127;					
					ELSE proximo_estado <= s126;
					END IF;	
				END IF;
			WHEN s127 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s128;					
					ELSE proximo_estado <= s127;
					END IF;	
				END IF;
			WHEN s128 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s129;					
					ELSE proximo_estado <= s128;
					END IF;	
				END IF;
			WHEN s129 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s130;					
					ELSE proximo_estado <= s129;
					END IF;	
				END IF;
			WHEN s130 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s131;					
					ELSE proximo_estado <= s130;
					END IF;	
				END IF;
			WHEN s131 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s132;					
					ELSE proximo_estado <= s131;
					END IF;	
				END IF;
			WHEN s132 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s133;					
					ELSE proximo_estado <= s132;
					END IF;	
				END IF;
			WHEN s133 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s134;					
					ELSE proximo_estado <= s133;
					END IF;	
				END IF;
			WHEN s134 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s135;					
					ELSE proximo_estado <= s134;
					END IF;	
				END IF;
			WHEN s135 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s136;					
					ELSE proximo_estado <= s135;
					END IF;	
				END IF;
			WHEN s136 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s137;					
					ELSE proximo_estado <= s136;
					END IF;	
				END IF;
			WHEN s137 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s138;					
					ELSE proximo_estado <= s137;
					END IF;	
				END IF;
			WHEN s138 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s139;					
					ELSE proximo_estado <= s138;
					END IF;	
				END IF;
			WHEN s139 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s140;					
					ELSE proximo_estado <= s139;
					END IF;	
				END IF;
			WHEN s140 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s141;					
					ELSE proximo_estado <= s140;
					END IF;	
				END IF;
			WHEN s141 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s142;					
					ELSE proximo_estado <= s141;
					END IF;	
				END IF;
			WHEN s142 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s143;					
					ELSE proximo_estado <= s142;
					END IF;	
				END IF;
			WHEN s143 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s144;					
					ELSE proximo_estado <= s143;
					END IF;	
				END IF;
			WHEN s144 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s145;					
					ELSE proximo_estado <= s144;
					END IF;	
				END IF;
			WHEN s145 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s146;					
					ELSE proximo_estado <= s145;
					END IF;	
				END IF;
			WHEN s146 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s147;					
					ELSE proximo_estado <= s146;
					END IF;	
				END IF;
			WHEN s147 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s148;					
					ELSE proximo_estado <= s147;
					END IF;	
				END IF;
			WHEN s148 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s149;					
					ELSE proximo_estado <= s148;
					END IF;	
				END IF;
			WHEN s149 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s150;					
					ELSE proximo_estado <= s149;
					END IF;	
				END IF;
			WHEN s150 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s151;					
					ELSE proximo_estado <= s150;
					END IF;	
				END IF;
			WHEN s151 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s152;					
					ELSE proximo_estado <= s151;
					END IF;	
				END IF;
			WHEN s152 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s153;					
					ELSE proximo_estado <= s152;
					END IF;	
				END IF;
			WHEN s153 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s154;					
					ELSE proximo_estado <= s153;
					END IF;	
				END IF;
			WHEN s154 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s155;					
					ELSE proximo_estado <= s154;
					END IF;	
				END IF;
			WHEN s155 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s156;					
					ELSE proximo_estado <= s155;
					END IF;	
				END IF;
			WHEN s156 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s157;					
					ELSE proximo_estado <= s156;
					END IF;	
				END IF;
			WHEN s157 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s158;					
					ELSE proximo_estado <= s157;
					END IF;	
				END IF;
			WHEN s158 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s159;					
					ELSE proximo_estado <= s158;
					END IF;	
				END IF;
			WHEN s159 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s160;					
					ELSE proximo_estado <= s159;
					END IF;	
				END IF;
			WHEN s160 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s161;					
					ELSE proximo_estado <= s160;
					END IF;	
				END IF;
			WHEN s161 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s162;					
					ELSE proximo_estado <= s161;
					END IF;	
				END IF;
			WHEN s162 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s163;					
					ELSE proximo_estado <= s162;
					END IF;	
				END IF;
			WHEN s163 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s164;					
					ELSE proximo_estado <= s163;
					END IF;	
				END IF;
			WHEN s164 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s165;					
					ELSE proximo_estado <= s164;
					END IF;	
				END IF;
			WHEN s165 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s166;					
					ELSE proximo_estado <= s165;
					END IF;	
				END IF;
			WHEN s166 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s167;					
					ELSE proximo_estado <= s166;
					END IF;	
				END IF;
			WHEN s167 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s168;					
					ELSE proximo_estado <= s167;
					END IF;	
				END IF;
			WHEN s168 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s169;					
					ELSE proximo_estado <= s168;
					END IF;	
				END IF;
			WHEN s169 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s170;					
					ELSE proximo_estado <= s169;
					END IF;	
				END IF;
			WHEN s170 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s171;					
					ELSE proximo_estado <= s170;
					END IF;	
				END IF;
			WHEN s171 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s172;					
					ELSE proximo_estado <= s171;
					END IF;	
				END IF;
			WHEN s172 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s173;					
					ELSE proximo_estado <= s172;
					END IF;	
				END IF;
			WHEN s173 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s174;					
					ELSE proximo_estado <= s173;
					END IF;	
				END IF;
			WHEN s174 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s175;					
					ELSE proximo_estado <= s174;
					END IF;	
				END IF;
			WHEN s175 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s176;					
					ELSE proximo_estado <= s175;
					END IF;	
				END IF;
			WHEN s176 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s177;					
					ELSE proximo_estado <= s176;
					END IF;	
				END IF;
			WHEN s177 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s178;					
					ELSE proximo_estado <= s177;
					END IF;	
				END IF;
			WHEN s178 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s179;					
					ELSE proximo_estado <= s178;
					END IF;	
				END IF;
			WHEN s179 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s180;					
					ELSE proximo_estado <= s179;
					END IF;	
				END IF;
			WHEN s180 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s181;					
					ELSE proximo_estado <= s180;
					END IF;	
				END IF;
			WHEN s181 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s182;					
					ELSE proximo_estado <= s181;
					END IF;	
				END IF;
			WHEN s182 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s183;					
					ELSE proximo_estado <= s182;
					END IF;	
				END IF;
			WHEN s183 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s184;					
					ELSE proximo_estado <= s183;
					END IF;	
				END IF;
			WHEN s184 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s185;					
					ELSE proximo_estado <= s184;
					END IF;	
				END IF;
			WHEN s185 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s186;					
					ELSE proximo_estado <= s185;
					END IF;	
				END IF;
			WHEN s186 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s187;					
					ELSE proximo_estado <= s186;
					END IF;	
				END IF;
			WHEN s187 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s188;					
					ELSE proximo_estado <= s187;
					END IF;	
				END IF;
			WHEN s188 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s189;					
					ELSE proximo_estado <= s188;
					END IF;	
				END IF;
			WHEN s189 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s190;					
					ELSE proximo_estado <= s189;
					END IF;	
				END IF;
			WHEN s190 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s191;					
					ELSE proximo_estado <= s190;
					END IF;	
				END IF;
			WHEN s191 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s192;					
					ELSE proximo_estado <= s191;
					END IF;	
				END IF;
			WHEN s192 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s193;					
					ELSE proximo_estado <= s192;
					END IF;	
				END IF;
			WHEN s193 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s194;					
					ELSE proximo_estado <= s193;
					END IF;	
				END IF;
			WHEN s194 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s195;					
					ELSE proximo_estado <= s194;
					END IF;	
				END IF;
			WHEN s195 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s196;					
					ELSE proximo_estado <= s195;
					END IF;	
				END IF;
			WHEN s196 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s197;					
					ELSE proximo_estado <= s196;
					END IF;	
				END IF;
			WHEN s197 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s198;					
					ELSE proximo_estado <= s197;
					END IF;	
				END IF;
			WHEN s198 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s199;					
					ELSE proximo_estado <= s198;
					END IF;	
				END IF;
			WHEN s199 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s200;					
					ELSE proximo_estado <= s199;
					END IF;	
				END IF;
			WHEN s200 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s201;					
					ELSE proximo_estado <= s200;
					END IF;	
				END IF;
			WHEN s201 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s202;					
					ELSE proximo_estado <= s201;
					END IF;	
				END IF;
			WHEN s202 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s203;					
					ELSE proximo_estado <= s202;
					END IF;	
				END IF;
			WHEN s203 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s204;					
					ELSE proximo_estado <= s203;
					END IF;	
				END IF;
			WHEN s204 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s205;					
					ELSE proximo_estado <= s204;
					END IF;	
				END IF;
			WHEN s205 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s206;					
					ELSE proximo_estado <= s205;
					END IF;	
				END IF;
			WHEN s206 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s207;					
					ELSE proximo_estado <= s206;
					END IF;	
				END IF;
			WHEN s207 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s208;					
					ELSE proximo_estado <= s207;
					END IF;	
				END IF;
			WHEN s208 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s209;					
					ELSE proximo_estado <= s208;
					END IF;	
				END IF;
			WHEN s209 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s210;					
					ELSE proximo_estado <= s209;
					END IF;	
				END IF;
			WHEN s210 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s211;					
					ELSE proximo_estado <= s210;
					END IF;	
				END IF;
			WHEN s211 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s212;					
					ELSE proximo_estado <= s211;
					END IF;	
				END IF;
			WHEN s212 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s213;					
					ELSE proximo_estado <= s212;
					END IF;	
				END IF;
			WHEN s213 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s214;					
					ELSE proximo_estado <= s213;
					END IF;	
				END IF;
			WHEN s214 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s215;					
					ELSE proximo_estado <= s214;
					END IF;	
				END IF;
			WHEN s215 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s216;					
					ELSE proximo_estado <= s215;
					END IF;	
				END IF;
			WHEN s216 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s217;					
					ELSE proximo_estado <= s216;
					END IF;	
				END IF;
			WHEN s217 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s218;					
					ELSE proximo_estado <= s217;
					END IF;	
				END IF;
			WHEN s218 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s219;					
					ELSE proximo_estado <= s218;
					END IF;	
				END IF;
			WHEN s219 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s220;					
					ELSE proximo_estado <= s219;
					END IF;	
				END IF;
			WHEN s220 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s221;					
					ELSE proximo_estado <= s220;
					END IF;	
				END IF;
			WHEN s221 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s222;					
					ELSE proximo_estado <= s221;
					END IF;	
				END IF;
			WHEN s222 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s223;					
					ELSE proximo_estado <= s222;
					END IF;	
				END IF;
			WHEN s223 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s224;					
					ELSE proximo_estado <= s223;
					END IF;	
				END IF;
			WHEN s224 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s225;					
					ELSE proximo_estado <= s224;
					END IF;	
				END IF;
			WHEN s225 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s226;					
					ELSE proximo_estado <= s225;
					END IF;	
				END IF;
			WHEN s226 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s227;					
					ELSE proximo_estado <= s226;
					END IF;	
				END IF;
			WHEN s227 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s228;					
					ELSE proximo_estado <= s227;
					END IF;	
				END IF;
			WHEN s228 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s229;					
					ELSE proximo_estado <= s228;
					END IF;	
				END IF;
			WHEN s229 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s230;					
					ELSE proximo_estado <= s229;
					END IF;	
				END IF;
			WHEN s230 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s231;					
					ELSE proximo_estado <= s230;
					END IF;	
				END IF;
			WHEN s231 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s232;					
					ELSE proximo_estado <= s231;
					END IF;	
				END IF;
			WHEN s232 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s233;					
					ELSE proximo_estado <= s232;
					END IF;	
				END IF;
			WHEN s233 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s234;					
					ELSE proximo_estado <= s233;
					END IF;	
				END IF;
			WHEN s234 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s235;					
					ELSE proximo_estado <= s234;
					END IF;	
				END IF;
			WHEN s235 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s236;					
					ELSE proximo_estado <= s235;
					END IF;	
				END IF;
			WHEN s236 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s237;					
					ELSE proximo_estado <= s236;
					END IF;	
				END IF;
			WHEN s237 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s238;					
					ELSE proximo_estado <= s237;
					END IF;	
				END IF;
			WHEN s238 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s239;					
					ELSE proximo_estado <= s238;
					END IF;	
				END IF;
			WHEN s239 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s240;					
					ELSE proximo_estado <= s239;
					END IF;	
				END IF;
			WHEN s240 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s241;					
					ELSE proximo_estado <= s240;
					END IF;	
				END IF;
			WHEN s241 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s242;					
					ELSE proximo_estado <= s241;
					END IF;	
				END IF;
			WHEN s242 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s243;					
					ELSE proximo_estado <= s242;
					END IF;	
				END IF;
			WHEN s243 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s244;					
					ELSE proximo_estado <= s243;
					END IF;	
				END IF;
			WHEN s244 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s245;					
					ELSE proximo_estado <= s244;
					END IF;	
				END IF;
			WHEN s245 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s246;					
					ELSE proximo_estado <= s245;
					END IF;	
				END IF;
			WHEN s246 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s247;					
					ELSE proximo_estado <= s246;
					END IF;	
				END IF;
			WHEN s247 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s248;					
					ELSE proximo_estado <= s247;
					END IF;	
				END IF;
			WHEN s248 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s249;					
					ELSE proximo_estado <= s248;
					END IF;	
				END IF;
			WHEN s249 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s250;					
					ELSE proximo_estado <= s249;
					END IF;	
				END IF;
			WHEN s250 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s251;					
					ELSE proximo_estado <= s250;
					END IF;	
				END IF;
			WHEN s251 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s252;					
					ELSE proximo_estado <= s251;
					END IF;	
				END IF;
			WHEN s252 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s253;					
					ELSE proximo_estado <= s252;
					END IF;	
				END IF;
			WHEN s253 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s254;					
					ELSE proximo_estado <= s253;
					END IF;	
				END IF;
			WHEN s254 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s255;					
					ELSE proximo_estado <= s254;
					END IF;	
				END IF;
			WHEN s255 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s256;					
					ELSE proximo_estado <= s255;
					END IF;	
				END IF;
			WHEN s256 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s257;					
					ELSE proximo_estado <= s256;
					END IF;	
				END IF;
			WHEN s257 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s258;					
					ELSE proximo_estado <= s257;
					END IF;	
				END IF;
			WHEN s258 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s259;					
					ELSE proximo_estado <= s258;
					END IF;	
				END IF;
			WHEN s259 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s260;					
					ELSE proximo_estado <= s259;
					END IF;	
				END IF;
			WHEN s260 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s261;					
					ELSE proximo_estado <= s260;
					END IF;	
				END IF;
			WHEN s261 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s262;					
					ELSE proximo_estado <= s261;
					END IF;	
				END IF;
			WHEN s262 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s263;					
					ELSE proximo_estado <= s262;
					END IF;	
				END IF;
			WHEN s263 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s264;					
					ELSE proximo_estado <= s263;
					END IF;	
				END IF;
			WHEN s264 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s265;					
					ELSE proximo_estado <= s264;
					END IF;	
				END IF;
			WHEN s265 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s266;					
					ELSE proximo_estado <= s265;
					END IF;	
				END IF;
			WHEN s266 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s267;					
					ELSE proximo_estado <= s266;
					END IF;	
				END IF;
			WHEN s267 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s268;					
					ELSE proximo_estado <= s267;
					END IF;	
				END IF;
			WHEN s268 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s269;					
					ELSE proximo_estado <= s268;
					END IF;	
				END IF;
			WHEN s269 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s270;					
					ELSE proximo_estado <= s269;
					END IF;	
				END IF;
			WHEN s270 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s271;					
					ELSE proximo_estado <= s270;
					END IF;	
				END IF;
			WHEN s271 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s272;					
					ELSE proximo_estado <= s271;
					END IF;	
				END IF;
			WHEN s272 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s273;					
					ELSE proximo_estado <= s272;
					END IF;	
				END IF;
			WHEN s273 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s274;					
					ELSE proximo_estado <= s273;
					END IF;	
				END IF;
			WHEN s274 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s275;					
					ELSE proximo_estado <= s274;
					END IF;	
				END IF;
			WHEN s275 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s276;					
					ELSE proximo_estado <= s275;
					END IF;	
				END IF;
			WHEN s276 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s277;					
					ELSE proximo_estado <= s276;
					END IF;	
				END IF;
			WHEN s277 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s278;					
					ELSE proximo_estado <= s277;
					END IF;	
				END IF;
			WHEN s278 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s279;					
					ELSE proximo_estado <= s278;
					END IF;	
				END IF;
			WHEN s279 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s280;					
					ELSE proximo_estado <= s279;
					END IF;	
				END IF;
			WHEN s280 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s281;					
					ELSE proximo_estado <= s280;
					END IF;	
				END IF;
			WHEN s281 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s282;					
					ELSE proximo_estado <= s281;
					END IF;	
				END IF;
			WHEN s282 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s283;					
					ELSE proximo_estado <= s282;
					END IF;	
				END IF;
			WHEN s283 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s284;					
					ELSE proximo_estado <= s283;
					END IF;	
				END IF;
			WHEN s284 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s285;					
					ELSE proximo_estado <= s284;
					END IF;	
				END IF;
			WHEN s285 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s286;					
					ELSE proximo_estado <= s285;
					END IF;	
				END IF;
			WHEN s286 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s287;					
					ELSE proximo_estado <= s286;
					END IF;	
				END IF;
			WHEN s287 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s288;					
					ELSE proximo_estado <= s287;
					END IF;	
				END IF;
			WHEN s288 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s289;					
					ELSE proximo_estado <= s288;
					END IF;	
				END IF;
			WHEN s289 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s290;					
					ELSE proximo_estado <= s289;
					END IF;	
				END IF;
			WHEN s290 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s291;					
					ELSE proximo_estado <= s290;
					END IF;	
				END IF;
			WHEN s291 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s292;					
					ELSE proximo_estado <= s291;
					END IF;	
				END IF;
			WHEN s292 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s293;					
					ELSE proximo_estado <= s292;
					END IF;	
				END IF;	
			WHEN s293 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s294;					
					ELSE proximo_estado <= s293;
					END IF;	
				END IF;
			WHEN s294 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s295;					
					ELSE proximo_estado <= s294;
					END IF;	
				END IF;
			WHEN s295 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s296;					
					ELSE proximo_estado <= s295;
					END IF;	
				END IF;
			WHEN s296 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s297;					
					ELSE proximo_estado <= s296;
					END IF;	
				END IF;
			WHEN s297 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s298;					
					ELSE proximo_estado <= s297;
					END IF;	
				END IF;
			WHEN s298 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s299;					
					ELSE proximo_estado <= s298;
					END IF;	
				END IF;
			WHEN s299 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s300;					
					ELSE proximo_estado <= s299;
					END IF;	
				END IF;
			WHEN s300 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s301;					
					ELSE proximo_estado <= s300;
					END IF;	
				END IF;
			WHEN s301 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s302;					
					ELSE proximo_estado <= s301;
					END IF;	
				END IF;
			WHEN s302 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s303;					
					ELSE proximo_estado <= s302;
					END IF;	
				END IF;
			WHEN s303 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s304;					
					ELSE proximo_estado <= s303;
					END IF;	
				END IF;
			WHEN s304 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s305;					
					ELSE proximo_estado <= s304;
					END IF;	
				END IF;
			WHEN s305 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s306;					
					ELSE proximo_estado <= s305;
					END IF;	
				END IF;
			WHEN s306 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s307;					
					ELSE proximo_estado <= s306;
					END IF;	
				END IF;
			WHEN s307 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s308;					
					ELSE proximo_estado <= s307;
					END IF;	
				END IF;
			WHEN s308 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s309;					
					ELSE proximo_estado <= s308;
					END IF;	
				END IF;
			WHEN s309 =>
				IF (Stop_in = '1') THEN
					proximo_estado <= s0;
				ELSE
					IF (Duracao = '0' and Play_in = '1') THEN
						proximo_estado <= s1;					
					ELSE proximo_estado <= s309;
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
				WHEN s2 => nota(E5, ov_t1_2);
				WHEN s3 => nota(0, ov_t1_2);
				WHEN s4 => nota(E5, ov_t1_2);
				WHEN s5 => nota(0, ov_t1_2);
				WHEN s6 => nota(C5, ov_t1_2);
				WHEN s7 => nota(E5, ov_t1_2);
				WHEN s8 => nota(G5, ov_t1);
				WHEN s9 => nota(0, ov_t1);
				WHEN s10 => nota(G4, ov_t1_2);
				WHEN s11 => nota(0, ov_t1);
				WHEN s12 => nota(C5, ov_t3_2);
				WHEN s13 => nota(G4, ov_t1_2);
				WHEN s14 => nota(0, ov_t1);
				WHEN s15 => nota(E4, ov_t3_2);
				WHEN s16 => nota(A4, ov_t1);
				WHEN s17 => nota(B4, ov_t1);
				WHEN s18 => nota(AS4, ov_t1_2);
				WHEN s19 => nota(A4, ov_t1);
				WHEN s20 => nota(G4, ov_t3_4);
				WHEN s21 => nota(E5, ov_t3_4);
				WHEN s22 => nota(G5, ov_t3_4);
				WHEN s23 => nota(A5, ov_t1);
				WHEN s24 => nota(F5, ov_t1_2);
				WHEN s25 => nota(G5, ov_t1_2);
				WHEN s26 => nota(0, ov_t1_2);
				WHEN s27 => nota(E5, ov_t1);
				WHEN s28 => nota(C5, ov_t1_2);
				WHEN s29 => nota(D5, ov_t1_2);
				WHEN s30 => nota(B4, ov_t3_2);
				WHEN s31 => nota(C5, ov_t3_2);
				WHEN s32 => nota(G4, ov_t1_2);
				WHEN s33 => nota(0, ov_t1);
				WHEN s34 => nota(E4, ov_t3_2);
				WHEN s35 => nota(A4, ov_t1);
				WHEN s36 => nota(B4, ov_t1);
				WHEN s37 => nota(AS4, ov_t1_2);
				WHEN s38 => nota(A4, ov_t1);
				WHEN s39 => nota(G4, ov_t3_4);
				WHEN s40 => nota(E5, ov_t3_4);
				WHEN s41 => nota(G5, ov_t3_4);
				WHEN s42 => nota(A5, ov_t1);
				WHEN s43 => nota(F5, ov_t1_2);
				WHEN s44 => nota(G5, ov_t1_2);
				WHEN s45 => nota(0, ov_t1_2);
				WHEN s46 => nota(E5, ov_t1);
				WHEN s47 => nota(C5, ov_t1_2);
				WHEN s48 => nota(D5, ov_t1_2);
				WHEN s49 => nota(B4, ov_t3_2);
				WHEN s50 => nota(0, ov_t1);
				WHEN s51 => nota(G5, ov_t1_2);
				WHEN s52 => nota(FS5, ov_t1_2);
				WHEN s53 => nota(F5, ov_t1_2);
				WHEN s54 => nota(DS5, ov_t1);
				WHEN s55 => nota(E5, ov_t1_2);
				WHEN s56 => nota(0, ov_t1_2);
				WHEN s57 => nota(GS4, ov_t1_2);
				WHEN s58 => nota(A4, ov_t1_2);
				WHEN s59 => nota(C4, ov_t1_2);
				WHEN s60 => nota(0, ov_t1_2);
				WHEN s61 => nota(A4, ov_t1_2);
				WHEN s62 => nota(C5, ov_t1_2);
				WHEN s63 => nota(D5, ov_t1_2);
				WHEN s64 => nota(0, ov_t1);
				WHEN s65 => nota(DS5, ov_t1);
				WHEN s66 => nota(0, ov_t1_2);
				WHEN s67 => nota(D5, ov_t3_2);
				WHEN s68 => nota(C5, ov_t2);
				WHEN s69 => nota(0, ov_t2);
				WHEN s70 => nota(0, ov_t1);
				WHEN s71 => nota(G5, ov_t1_2);
				WHEN s72 => nota(FS5, ov_t1_2);
				WHEN s73 => nota(F5, ov_t1_2);
				WHEN s74 => nota(DS5, ov_t1);
				WHEN s75 => nota(E5, ov_t1_2);
				WHEN s76 => nota(0, ov_t1_2);
				WHEN s77 => nota(GS4, ov_t1_2);
				WHEN s78 => nota(A4, ov_t1_2);
				WHEN s79 => nota(C4, ov_t1_2);
				WHEN s80 => nota(0, ov_t1_2);
				WHEN s81 => nota(A4, ov_t1_2);
				WHEN s82 => nota(C5, ov_t1_2);
				WHEN s83 => nota(D5, ov_t1_2);
				WHEN s84 => nota(0, ov_t1);
				WHEN s85 => nota(DS5, ov_t1);
				WHEN s86 => nota(0, ov_t1_2);
				WHEN s87 => nota(D5, ov_t3_2);
				WHEN s88 => nota(C5, ov_t2);
				WHEN s89 => nota(0, ov_t2);
				WHEN s90 => nota(C5, ov_t1_2);
				WHEN s91 => nota(C4, ov_t1);
				WHEN s92 => nota(C5, ov_t1_2);
				WHEN s93 => nota(0, ov_t1_2);
				WHEN s94 => nota(C5, ov_t1_2);
				WHEN s95 => nota(D5, ov_t1);
				WHEN s96 => nota(E5, ov_t1_2);
				WHEN s97 => nota(C5, ov_t1);
				WHEN s98 => nota(A4, ov_t1_2);
				WHEN s99 => nota(G4, ov_t2);
				WHEN s100 => nota(C5, ov_t1_2);
				WHEN s101 => nota(C4, ov_t1);
				WHEN s102 => nota(C5, ov_t1_2);
				WHEN s103 => nota(0, ov_t1_2);
				WHEN s104 => nota(C5, ov_t1_2);
				WHEN s105 => nota(D5, ov_t1_2);
				WHEN s106 => nota(E5, ov_t1_2);
				WHEN s107 => nota(0, ov_t4);
				WHEN s108 => nota(C5, ov_t1_2);
				WHEN s109 => nota(C4, ov_t1);
				WHEN s110 => nota(C5, ov_t1_2);
				WHEN s111 => nota(0, ov_t1_2);
				WHEN s112 => nota(C5, ov_t1_2);
				WHEN s113 => nota(D5, ov_t1);
				WHEN s114 => nota(E5, ov_t1_2);
				WHEN s115 => nota(C5, ov_t1);
				WHEN s116 => nota(A4, ov_t1_2);
				WHEN s117 => nota(G4, ov_t2);
				WHEN s118 => nota(E5, ov_t1_2);
				WHEN s119 => nota(E5, ov_t1_2);
				WHEN s120 => nota(0, ov_t1_2);
				WHEN s121 => nota(E5, ov_t1_2);
				WHEN s122 => nota(0, ov_t1_2);
				WHEN s123 => nota(C5, ov_t1_2);
				WHEN s124 => nota(E5, ov_t1);
				WHEN s125 => nota(G5, ov_t1);
				WHEN s126 => nota(0, ov_t1);
				WHEN s127 => nota(G4, ov_t1);
				WHEN s128 => nota(0, ov_t1);
				WHEN s129 => nota(C5, ov_t3_2);
				WHEN s130 => nota(G4, ov_t1_2);
				WHEN s131 => nota(0, ov_t1);
				WHEN s132 => nota(E4, ov_t3_2);
				WHEN s133 => nota(A4, ov_t1);
				WHEN s134 => nota(B4, ov_t1);
				WHEN s135 => nota(AS4, ov_t1_2);
				WHEN s136 => nota(A4, ov_t1);
				WHEN s137 => nota(G4, ov_t3_4);
				WHEN s138 => nota(E5, ov_t3_4);
				WHEN s139 => nota(G5, ov_t3_4);
				WHEN s140 => nota(A5, ov_t1);
				WHEN s141 => nota(F5, ov_t1_2);
				WHEN s142 => nota(G5, ov_t1_2);
				WHEN s143 => nota(0, ov_t1_2);
				WHEN s144 => nota(E5, ov_t1);
				WHEN s145 => nota(C5, ov_t1_2);
				WHEN s146 => nota(D5, ov_t3_2);
				WHEN s147 => nota(B4, ov_t3_2);
				WHEN s148 => nota(C5, ov_t3_2);
				WHEN s149 => nota(G4, ov_t1_2);
				WHEN s150 => nota(0, ov_t1);
				WHEN s151 => nota(E4, ov_t3_2);
				WHEN s152 => nota(A4, ov_t1);
				WHEN s153 => nota(B4, ov_t1);
				WHEN s154 => nota(AS4, ov_t1_2);
				WHEN s155 => nota(A4, ov_t1);
				WHEN s156 => nota(G4, ov_t3_4);
				WHEN s157 => nota(E5, ov_t3_4);
				WHEN s158 => nota(G5, ov_t3_4);
				WHEN s159 => nota(A5, ov_t1);
				WHEN s160 => nota(F5, ov_t1_2);
				WHEN s161 => nota(G5, ov_t1_2);
				WHEN s162 => nota(0, ov_t1_2);
				WHEN s163 => nota(E5, ov_t1);
				WHEN s164 => nota(C5, ov_t1_2);
				WHEN s165 => nota(D5, ov_t3_2);
				WHEN s166 => nota(B4, ov_t3_2);
				WHEN s167 => nota(E5, ov_t1_2);
				WHEN s168 => nota(C5, ov_t1);
				WHEN s169 => nota(G4, ov_t1_2);
				WHEN s170 => nota(0, ov_t1);
				WHEN s171 => nota(GS4, ov_t1);
				WHEN s172 => nota(A4, ov_t1_2);
				WHEN s173 => nota(F5, ov_t1);
				WHEN s174 => nota(F5, ov_t1_2);
				WHEN s175 => nota(A4, ov_t2);
				WHEN s176 => nota(D5, ov_t3_4);
				WHEN s177 => nota(A5, ov_t3_4);
				WHEN s178 => nota(A4, ov_t3_4);
				WHEN s179 => nota(A5, ov_t3_4);
				WHEN s180 => nota(G5, ov_t3_4);
				WHEN s181 => nota(F5, ov_t3_4);
				WHEN s182 => nota(E5, ov_t1_2);
				WHEN s183 => nota(C5, ov_t1);
				WHEN s184 => nota(A4, ov_t1_2);
				WHEN s185 => nota(G4, ov_t2);
				WHEN s186 => nota(E5, ov_t1_2);
				WHEN s187 => nota(C5, ov_t1);
				WHEN s188 => nota(G4, ov_t1_2);
				WHEN s189 => nota(0, ov_t1);
				WHEN s190 => nota(GS4, ov_t1);
				WHEN s191 => nota(A4, ov_t1_2);
				WHEN s192 => nota(F5, ov_t1);
				WHEN s193 => nota(F5, ov_t1_2);
				WHEN s194 => nota(A4, ov_t2);
				WHEN s195 => nota(B4, ov_t1_2);
				WHEN s196 => nota(F5, ov_t1);
				WHEN s197 => nota(F4, ov_t1_2);
				WHEN s198 => nota(F5, ov_t3_4);
				WHEN s199 => nota(E5, ov_t3_4);
				WHEN s200 => nota(D5, ov_t3_4);
				WHEN s201 => nota(C5, ov_t1_2);
				WHEN s202 => nota(E4, ov_t1);
				WHEN s203 => nota(E4, ov_t1_2);
				WHEN s204 => nota(C4, ov_t2);
				WHEN s205 => nota(E5, ov_t1_2);
				WHEN s206 => nota(C5, ov_t1);
				WHEN s207 => nota(G4, ov_t1_2);
				WHEN s208 => nota(0, ov_t1);
				WHEN s209 => nota(GS4, ov_t1);
				WHEN s210 => nota(A4, ov_t1_2);
				WHEN s211 => nota(F5, ov_t1);
				WHEN s212 => nota(F5, ov_t1_2);
				WHEN s213 => nota(A4, ov_t2);
				WHEN s214 => nota(D5, ov_t3_4);
				WHEN s215 => nota(A5, ov_t3_4);
				WHEN s216 => nota(A4, ov_t3_4);
				WHEN s217 => nota(A5, ov_t3_4);
				WHEN s218 => nota(G5, ov_t3_4);
				WHEN s219 => nota(F5, ov_t3_4);
				WHEN s220 => nota(E5, ov_t1_2);
				WHEN s221 => nota(C5, ov_t1);
				WHEN s222 => nota(A4, ov_t1_2);
				WHEN s223 => nota(G4, ov_t2);
				WHEN s224 => nota(E5, ov_t1_2);
				WHEN s225 => nota(C5, ov_t1);
				WHEN s226 => nota(G4, ov_t1_2);
				WHEN s227 => nota(0, ov_t1);
				WHEN s228 => nota(GS4, ov_t1);
				WHEN s229 => nota(A4, ov_t1_2);
				WHEN s230 => nota(F5, ov_t1);
				WHEN s231 => nota(F5, ov_t1_2);
				WHEN s232 => nota(A4, ov_t2);
				WHEN s233 => nota(B4, ov_t1_2);
				WHEN s234 => nota(F5, ov_t1);
				WHEN s235 => nota(F4, ov_t1_2);
				WHEN s236 => nota(F5, ov_t3_4);
				WHEN s237 => nota(E5, ov_t3_4);
				WHEN s238 => nota(D5, ov_t3_4);
				WHEN s239 => nota(C5, ov_t1_2);
				WHEN s240 => nota(E4, ov_t1);
				WHEN s241 => nota(E4, ov_t1_2);
				WHEN s242 => nota(C4, ov_t2);
				WHEN s243 => nota(C5, ov_t1_2);
				WHEN s244 => nota(C4, ov_t1);
				WHEN s245 => nota(C5, ov_t1_2);
				WHEN s246 => nota(0, ov_t1_2);
				WHEN s247 => nota(C5, ov_t1_2);
				WHEN s248 => nota(D5, ov_t1_2);
				WHEN s249 => nota(E5, ov_t1_2);
				WHEN s250 => nota(0, ov_t4);
				WHEN s251 => nota(C5, ov_t1_2);
				WHEN s252 => nota(C4, ov_t1);
				WHEN s253 => nota(C5, ov_t1_2);
				WHEN s254 => nota(0, ov_t1_2);
				WHEN s255 => nota(C5, ov_t1_2);
				WHEN s256 => nota(D5, ov_t1);
				WHEN s257 => nota(E5, ov_t1_2);
				WHEN s258 => nota(C5, ov_t1);
				WHEN s259 => nota(A4, ov_t1_2);
				WHEN s260 => nota(G4, ov_t2);
				WHEN s261 => nota(E5, ov_t1_2);
				WHEN s262 => nota(E5, ov_t1_2);
				WHEN s263 => nota(0, ov_t1_2);
				WHEN s264 => nota(E5, ov_t1_2);
				WHEN s265 => nota(0, ov_t1_2);
				WHEN s266 => nota(C5, ov_t1_2);
				WHEN s267 => nota(E5, ov_t1);
				WHEN s268 => nota(G5, ov_t1);
				WHEN s269 => nota(0, ov_t1);
				WHEN s270 => nota(G4, ov_t1);
				WHEN s271 => nota(0, ov_t1);
				WHEN s272 => nota(E5, ov_t1_2);
				WHEN s273 => nota(C5, ov_t1);
				WHEN s274 => nota(G4, ov_t1_2);
				WHEN s275 => nota(0, ov_t1);
				WHEN s276 => nota(GS4, ov_t1);
				WHEN s277 => nota(A4, ov_t1_2);
				WHEN s278 => nota(F5, ov_t1);
				WHEN s279 => nota(F5, ov_t1_2);
				WHEN s280 => nota(A4, ov_t2);
				WHEN s281 => nota(D5, ov_t3_4);
				WHEN s282 => nota(A5, ov_t3_4);
				WHEN s283 => nota(A4, ov_t3_4);
				WHEN s284 => nota(A5, ov_t3_4);
				WHEN s285 => nota(G5, ov_t3_4);
				WHEN s286 => nota(F5, ov_t3_4);
				WHEN s287 => nota(E5, ov_t1_2);
				WHEN s288 => nota(C5, ov_t1);
				WHEN s289 => nota(A4, ov_t1_2);
				WHEN s290 => nota(G4, ov_t2);
				WHEN s291 => nota(E5, ov_t1_2);
				WHEN s292 => nota(C4, ov_t1);
				WHEN s293 => nota(G4, ov_t1_2);
				WHEN s294 => nota(0, ov_t1);
				WHEN s295 => nota(GS4, ov_t1);
				WHEN s296 => nota(A4, ov_t1_2);
				WHEN s297 => nota(F5, ov_t1);
				WHEN s298 => nota(F5, ov_t1_2);
				WHEN s299 => nota(A4, ov_t2);
				WHEN s300 => nota(B4, ov_t1_2);
				WHEN s301 => nota(F5, ov_t1);
				WHEN s302 => nota(F4, ov_t1_2);
				WHEN s303 => nota(F5, ov_t3_4);
				WHEN s304 => nota(E5, ov_t3_4);
				WHEN s305 => nota(D5, ov_t3_4);
				WHEN s306 => nota(C5, ov_t1_2);
				WHEN s307 => nota(E4, ov_t1);
				WHEN s308 => nota(E4, ov_t1_2);
				WHEN s309 => nota(C4, ov_t2);
				
--Não é necessário WHEN OTHERS pois o controle é feito no processo L2
			END CASE;
		END IF;
	END PROCESS L3;
	
	--Atribuição contínua
	Clk_out <= Duracao AND Clk_in;
END bhv;