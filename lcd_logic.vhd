LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY lcd_logic IS
  PORT( 	clk      : IN  STD_LOGIC;  --clock principal			
			lcd_busy : IN  STD_LOGIC;  --feedback do controlador (1)ocupado/(0)disponível		
			--key		: IN 	STD_LOGIC_VECTOR(4 DOWNTO 1); --botões
			q  		: IN 	STD_LOGIC_VECTOR(7 DOWNTO 1);
			lcd_e 	: OUT STD_LOGIC;  --retem os dados no controlador LCD
			lcd_bar	: OUT STD_LOGIC_VECTOR(9 DOWNTO 0)  --(9) rs (8) rw (7..0) dado char
		);
END lcd_logic;
ARCHITECTURE bhv OF lcd_logic IS
	--Registradores
	SIGNAL lcd_enable : STD_LOGIC;
	SIGNAL lcd_bus    : STD_LOGIC_VECTOR(9 DOWNTO 0);
	--Barramento de dados do display
	SIGNAL L1 : std_logic_vector (127 DOWNTO 0);
	SIGNAL L2 : std_logic_vector (127 DOWNTO 0);
	
	--constantes
	CONSTANT musica_1 : std_logic_vector (127 DOWNTO 0) := B"00100000_00100000_00100000_00100000_01000110_01110101_01110010_00100000_01000101_01101100_01101001_01110011_01100101_00100000_00100000_00100000";--16 caracteres!!!
	CONSTANT autor_1 : std_logic_vector (127 DOWNTO 0) := B"01001100_01110101_01100100_01110111_01101001_01100111_00100000_01000010_01100101_01100101_01110100_01101000_01101111_01110110_01100101_01101110";--16 caracteres!!!
	CONSTANT musica_2 : std_logic_vector (127 DOWNTO 0) := B"00100000_01001111_01110110_01100101_01110010_00100000_01010100_01101000_01100101_00100000_01010111_01100001_01110110_01100101_01110011_00100000";--16 caracteres!!!
	CONSTANT autor_2 : std_logic_vector (127 DOWNTO 0) := B"01001010_01110101_01110110_01100101_01101110_01110100_01101001_01101110_01101111_00100000_01010010_01101111_01110011_01100001_01110011_00100000";--16 caracteres!!!
	CONSTANT musica_3 : std_logic_vector (127 DOWNTO 0) := B"01001111_01110110_01100101_01110010_00100000_01010100_01101000_01100101_00100000_01010010_01100001_01101001_01101110_01100010_01101111_01110111";--16 caracteres!!!
	CONSTANT autor_3 : std_logic_vector (127 DOWNTO 0) := B"00100000_00100000_01011001_01101001_01110000_00100000_01001000_01100001_01110010_01100010_01110101_01110010_01100111_00100000_00100000_00100000";--16 caracteres!!!
	CONSTANT musica_4 : std_logic_vector (127 DOWNTO 0) := B"00100000_00100000_01000110_01110010_01100101_01110010_01100101_00100000_01001010_01100001_01100011_01110001_01110101_01100101_00100000_00100000";--16 caracteres!!!
	CONSTANT autor_4 : std_logic_vector (127 DOWNTO 0) := B"01010000_01101111_01110000_01110101_01101100_01100001_01110010_00100000_01000110_01110010_01100001_01101110_01100011_01100101_01110011_01100001";--16 caracteres!!!
	CONSTANT musica_5 : std_logic_vector (127 DOWNTO 0) := B"00100000_00100000_01001000_01100001_01110010_01110010_01111001_00100000_01010000_01101111_01110100_01110100_01100101_01110010_00100000_00100000";--16 caracteres!!!
	CONSTANT autor_5 : std_logic_vector (127 DOWNTO 0) := B"00100000_00100000_01001010_01101111_01101000_01101110_00100000_01010111_01101001_01101100_01101100_01101001_01100001_01101110_01110011_00100000";--16 caracteres!!!
	CONSTANT musica_6 : std_logic_vector (127 DOWNTO 0) := B"00100000_00100000_00100000_01001110_01101111_01101011_01101001_01100001_00100000_01010100_01110101_01101110_01100101_00100000_00100000_00100000";--16 caracteres!!!
	CONSTANT autor_6 : std_logic_vector (127 DOWNTO 0) := B"01000110_01110010_01100001_01101110_01100011_01101001_01110011_01100011_01101111_01010100_01100001_01110010_01110010_01100101_01100111_01100001";--16 caracteres!!!
	CONSTANT musica_7 : std_logic_vector (127 DOWNTO 0) := B"00100000_00010000_00100000_01001101_01100001_01110010_01101001_01101111_00100000_01010100_01101000_01100101_01101101_01100101_00100000_00100000";--16 caracteres!!!
	CONSTANT autor_7 : std_logic_vector (127 DOWNTO 0) := B"00100000_00100000_00100000_01001011_01101111_01101010_01101001_00100000_01001011_01101111_01101110_01100100_01101111_00100000_00100000_00100000";--16 caracteres!!!
BEGIN
	--atribuição contínua das saídas registradas
	lcd_e <= lcd_enable;
	lcd_bar <= lcd_bus; 
	
	--seleção do conteúdo através do key1
	P1: PROCESS(clk)
	BEGIN
		IF (q = B"0000001") THEN
			L1 <= musica_1;
		END IF;
		IF (q = B"0000010") THEN
			L1 <= musica_2;
		END IF;
		IF (q = B"0000100") THEN
			L1 <= musica_3;
		END IF;
		IF (q = B"0001000") THEN
			L1 <= musica_4;
		END IF;
		IF (q = B"0010000") THEN
			L1 <= musica_5;
		END IF;
		IF (q = B"0100000") THEN
			L1 <= musica_6;
		END IF;
		IF (q = B"1000000") THEN
			L1 <= musica_7;
		END IF;
	END PROCESS;
	
	P2: PROCESS(clk)
	BEGIN
		IF (q = B"0000001") THEN
			L2 <= autor_1;
		END IF;
		IF (q = B"0000010") THEN
			L2 <= autor_2;
		END IF;
		IF (q = B"0000100") THEN
			L2 <= autor_3;
		END IF;
		IF (q = B"0001000") THEN
			L2 <= autor_4;
		END IF;
		IF (q = B"0010000") THEN
			L2 <= autor_5;
		END IF;
		IF (q = B"0100000") THEN
			L2 <= autor_6;
		END IF;
		IF (q = B"1000000") THEN
			L2 <= autor_7;
		END IF;
	END PROCESS;
	
  --Sequenciamento do envio de cada caractere de L1 e L2
  P3: PROCESS(clk)
    VARIABLE char  :  INTEGER RANGE 0 TO 34 := 0; --6 bits
  BEGIN
    IF rising_edge(clk) THEN
      IF (lcd_busy = '0' AND lcd_enable = '0') THEN
        lcd_enable <= '1'; --habilita o LCD
        IF (char < 34) THEN
          char := char + 1; --incrementa o estado
			ELSE char := 0; --reinicia o estado
        END IF;
        CASE char IS --verifica o estado atual
			 WHEN 0  => lcd_bus <= "00" & "10000000"; --inst. linha 1
          WHEN 1  => lcd_bus <= "10" & L1(127 DOWNTO 120); --prim. char da linha 1
          WHEN 2  => lcd_bus <= "10" & L1(119 DOWNTO 112);
          WHEN 3  => lcd_bus <= "10" & L1(111 DOWNTO 104);
          WHEN 4  => lcd_bus <= "10" & L1(103 DOWNTO 96);
          WHEN 5  => lcd_bus <= "10" & L1(95 DOWNTO 88);
          WHEN 6  => lcd_bus <= "10" & L1(87 DOWNTO 80);
          WHEN 7  => lcd_bus <= "10" & L1(79 DOWNTO 72);
          WHEN 8  => lcd_bus <= "10" & L1(71 DOWNTO 64);
          WHEN 9  => lcd_bus <= "10" & L1(63 DOWNTO 56);
			 WHEN 10 => lcd_bus <= "10" & L1(55 DOWNTO 48);
			 WHEN 11 => lcd_bus <= "10" & L1(47 DOWNTO 40);
			 WHEN 12 => lcd_bus <= "10" & L1(39 DOWNTO 32);
			 WHEN 13 => lcd_bus <= "10" & L1(31 DOWNTO 24);
			 WHEN 14 => lcd_bus <= "10" & L1(23 DOWNTO 16);
			 WHEN 15 => lcd_bus <= "10" & L1(15 DOWNTO 8);
			 WHEN 16 => lcd_bus <= "10" & L1(7 DOWNTO 0); --ult char da linha 1
			 WHEN 17 => lcd_bus <= "00" & "11000000"; --inst. linha 2
          WHEN 18 => lcd_bus <= "10" & L2(127 DOWNTO 120); --prim. char da linha 2
          WHEN 19 => lcd_bus <= "10" & L2(119 DOWNTO 112);
          WHEN 20 => lcd_bus <= "10" & L2(111 DOWNTO 104);
          WHEN 21 => lcd_bus <= "10" & L2(103 DOWNTO 96);
          WHEN 22 => lcd_bus <= "10" & L2(95 DOWNTO 88);
          WHEN 23 => lcd_bus <= "10" & L2(87 DOWNTO 80);
          WHEN 24 => lcd_bus <= "10" & L2(79 DOWNTO 72);
          WHEN 25 => lcd_bus <= "10" & L2(71 DOWNTO 64);
          WHEN 26 => lcd_bus <= "10" & L2(63 DOWNTO 56);
			 WHEN 27 => lcd_bus <= "10" & L2(55 DOWNTO 48);
			 WHEN 28 => lcd_bus <= "10" & L2(47 DOWNTO 40);
			 WHEN 29 => lcd_bus <= "10" & L2(39 DOWNTO 32);
			 WHEN 30 => lcd_bus <= "10" & L2(31 DOWNTO 24);
			 WHEN 31 => lcd_bus <= "10" & L2(23 DOWNTO 16);
			 WHEN 32 => lcd_bus <= "10" & L2(15 DOWNTO 8);
			 WHEN 33 => lcd_bus <= "10" & L2(7 DOWNTO 0);--ult. char da linha 2			 
          WHEN OTHERS => lcd_enable <= '0'; --desabilita o LCD
        END CASE;
      ELSE
        lcd_enable <= '0'; --desabilita o LCD
      END IF;
    END IF;
  END PROCESS;
END bhv;
