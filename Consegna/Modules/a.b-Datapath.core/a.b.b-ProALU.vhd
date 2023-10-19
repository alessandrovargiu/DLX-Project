library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity ProAlu is

    generic( Nbit: integer := 32;
             OperationSelNbit: integer := 6);
    port( OperandA:     in std_logic_vector(Nbit-1 downto 0);
          OperandB:     in std_logic_vector(Nbit-1 downto 0);
          OperationSel: in std_logic_vector(6-1 downto 0);
          ALUOut:       out std_logic_vector(Nbit-1 downto 0)
          );
end ProAlu;

architecture struct of ProAlu is



----components used

--Logical operations component (T2 method)
component Logic is 
    generic ( Nbit: integer := 32
    );
	Port(A:	In	std_logic_vector(Nbit-1 downto 0); --input
		 B:	In	std_logic_vector(Nbit-1 downto 0); --input
		 S:	In	std_logic_vector(4-1 downto 0); --opcode for logic (know as selectN from lecture notes)
         C:  Out std_logic_vector(Nbit-1 downto 0)); --output    
end component;
			
--component used for shifting instructions (T2 methodology)
component Shifter is 
    generic (
        Nbit: integer := 32-- Nbit 32 bit
        );
	Port(A:	In	std_logic_vector(Nbit-1 downto 0); --input
		 B:	In	std_logic_vector(5-1 downto 0); --input bits shift , 5 o 6 bit?
         OP:  In  std_logic_vector(2-1 downto 0); -- input left or right
         S:  Out std_logic_vector(Nbit-1 downto 0)); --output 
    
end component;

--component used for addition and subtraction instructions (P4 sparse tree structure)
component p4_adder is
  generic (NBIT:integer :=32;
           NBIT_PER_BLOCK: integer);
  port(A : in std_logic_vector(NBIT-1 downto 0);
       B : in std_logic_vector(NBIT-1 downto 0);
       Cin : in	std_logic;
       S : out std_logic_vector(NBIT-1 downto 0);
       Cout : out std_logic);
end component; 

component ToplevelComparator is 
    generic (
            Nbit:integer := 32
    );
	Port (	Sub:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic; --input from p4 adder
            A:      In std_logic_vector (Nbit-1 downto 0);
            B:      In std_logic_vector (Nbit-1 downto 0);
            res:    Out std_logic_vector(Nbit-1 downto 0); --output
            op:     In std_logic_vector (2 downto 0)
    );
    end component;

component mux41_Generic is
	generic (Nbit : integer := 32);
    port(
         A: In std_logic_vector (Nbit-1 downto 0);
         B: In std_logic_vector (Nbit-1 downto 0);
         C: In std_logic_vector (Nbit-1 downto 0);
         D: In std_logic_vector (Nbit-1 downto 0);
         sel: In std_logic_vector(2-1 downto 0);
         E: Out std_logic_vector (Nbit-1 downto 0)

    );
end component;


signal resultAdd:       std_logic_vector(Nbit-1 downto 0);
signal resultLogic:     std_logic_vector(Nbit-1 downto 0);
signal resultShifter:   std_logic_vector(Nbit-1 downto 0);
signal resultComparator:   std_logic_vector(Nbit-1 downto 0);
signal Cout_s: std_logic;

begin

    Addition: p4_adder
    generic map(Nbit, 4)   --need to figure out what to put for nbit per block generic parameter
    port map(A => OperandA, B => operandB , Cin => Operationsel(2), S => resultAdd, Cout => cout_s);

    LogicalStuff: Logic
    generic map(Nbit)
    port map(A => operandA, B => operandB, S => Operationsel (5 downto 2), C => resultLogic);
     
    Shift: shifter
    generic map(Nbit)
    port map(A => OperandA, B => operandB(5-1 downto 0), OP => Operationsel (3 downto 2), S => resultShifter);

    Comp: Toplevelcomparator
    generic map(Nbit)
    port map(Sub => resultAdd, Cout => cout_s, A => OperandA, B => OperandB, res => resultComparator, op => Operationsel (5 downto 3) );

    Mux: Mux41_Generic
    generic map (Nbit)
    port map(A => resultAdd, B => resultShifter , C =>  resultComparator, D => resultLogic, sel => Operationsel (1 downto 0), E => ALUOut);

    end struct;
