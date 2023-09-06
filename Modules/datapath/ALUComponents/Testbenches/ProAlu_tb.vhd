library IEEE;
use IEEE.std_logic_1164.all; 
--use WORK.constants.all; 

entity tb_PROAlu is
end tb_PROAlu;

architecture test of tb_PROAlu is
component ProAlu IS 
	GENERIC (
		NBit: integer:=32;			
		OperationSelNbit: integer := 6
	);
	PORT(
		
		OPERANDA: in  std_logic_vector(Nbit-1 downto 0);
		OPERANDB: in  std_logic_vector(Nbit-1 downto 0);
		OPERATIONSEL: 	in  std_logic_vector(5 downto 0);
		ALUOut: 	out std_logic_vector(Nbit-1 downto 0)
	);
end component;

constant NBIT: integer := 32;
signal OPERANDA_s:  std_logic_vector(NBIT-1 downto 0);
signal OPERANDB_s:  std_logic_vector(NBIT-1 downto 0);
signal OperationSel_s: 	  std_logic_vector(5 downto 0);
signal ALUOut_s: 	std_logic_vector(NBIT-1 downto 0);

begin
	
	uut: ProAlu generic map(NBIT,6) port map(OPERANDA_s,OPERANDB_s,Operationsel_s,ALUOut_s);
	process
	begin	--ADD test
		OPERANDA_s <= x"0000002a";
		OPERANDB_s <= x"ffffaaaa";
		Operationsel_s <= "111000";
		wait for 10 ns;
		--SUB test
		OPERANDA_s <= "00000000000000001000010001011000";
		OPERANDB_s <= "00000000000000000000000111100111";
		Operationsel_s <= "010100";
		wait for 10 ns;
		--AND test
		OPERANDA_s <= "00000000000000001000010001011000";
		OPERANDB_s <= "00000000000000000000001111111111";
		Operationsel_s <= "100011";
		wait for 10 ns;
		--OR test
		OPERANDA_s <= "00000000000000001000010001011000";
		OPERANDB_s <= "00000000000000000000100001110111";
		Operationsel_s <= "111011";
		wait for 10 ns;
		--XOR test
		OPERANDA_s <= "00000000000000001000010001011000";
		OPERANDB_s <= "00000000000000000000111001110000";
		Operationsel_s <= "011011";
		wait for 10 ns;
		OPERANDA_s <= (OTHERS=>'0');
		OPERANDB_s <= (OTHERS=>'0');
		Operationsel_s <=   (OTHERS=>'0');
		wait for 10 ns;
		--SLL test
		OPERANDA_s <= "00000000000000001000010001011000";
		OPERANDB_s <= x"00000001";
		Operationsel_s <= "000001";
		wait for 10 ns;
		OPERANDA_s <= (OTHERS=>'0');
		OPERANDB_s <= (OTHERS=>'0');
		Operationsel_s <=   (OTHERS=>'0');
		wait for 10 ns;
		--SGE 
		OPERANDA_s <= x"00000000";
		OPERANDB_s <= x"00000001";
		Operationsel_s <=   "001110";
		wait for 10 ns;
		OPERANDA_s <= (OTHERS=>'0');
		OPERANDB_s <= (OTHERS=>'0');
		Operationsel_s <=   (OTHERS=>'0');
		wait for 10 ns;
		wait;
  end process;
end test;