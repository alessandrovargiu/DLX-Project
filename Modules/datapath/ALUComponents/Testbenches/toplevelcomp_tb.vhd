library IEEE;
use IEEE.std_logic_1164.all; 


entity tb is
end tb;

architecture test of tb is

component topLevelcomparator is
	GENERIC (Nbit: integer := 4);								--THIS TESTBENCH WAS MADE ON N = 4 bits, for simplicity
	PORT(SUM: IN std_logic_vector(Nbit-1 downto 0);
	     Cout: IN std_logic;
         A:	In std_logic_vector (Nbit-1 downto 0);	
	     B:  In std_logic_vector (Nbit-1 downto 0);				 
	     res: OUT std_logic_vector(Nbit-1 DOWNTO 0); 
	     OP: IN std_logic_vector(2 downto 0));
end component;																		

constant N: integer := NumBit;
signal A,B: std_logic_vector(3 DOWNTO 0);
signal C: std_logic;
signal Sel: std_logic_vector(2 DOWNTO 0);
signal Res: std_logic_vector(N-1 DOWNTO 0);

begin
	UUT: topLevelCMP generic map (N) port map(SUB,C,Sel,Res);
	PROCESS
		begin
		A<= 0001
		B<= 0001
		C <= '1';
		Sel<="000";
		wait for 5 ns;
		Sel<="001";
		wait for 5 ns;
		Sel<="010";
		wait for 5 ns;
		Sel<="011";
		wait for 5 ns;
		Sel<="100";
		wait for 5 ns;
		Sel<="101";
		wait for 5 ns;
		A<="0010";
		B<="0011";
		C <= '0';
		Sel<="000";
		wait for 5 ns;
		Sel<="001";
		wait for 5 ns;
		Sel<="010";
		wait for 5 ns;
		Sel<="011";
		wait for 5 ns;
		Sel<="100";
		wait for 5 ns;
		Sel<="101";
		wait for 5 ns;
		A<=0111
		B<= 0011
		C <= '1';
		Sel<="000";
		wait for 5 ns;
		Sel<="001";
		wait for 5 ns;
		Sel<="010";
		wait for 5 ns;
		Sel<="011";
		wait for 5 ns;
		Sel<="100";
		wait for 5 ns;
		Sel<="101";
		wait;

  END PROCESS;
end test;