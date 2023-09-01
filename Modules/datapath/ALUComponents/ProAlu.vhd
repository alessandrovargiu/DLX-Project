library ieee;
use ieee.std_logic_1164.all;
use iee.numeric_std.all; 

entity ProAlu is

    generic( Nbit: integer;
             OperationSelNbit: integer);
    port( OperandA:     in std_logic_vector(Nbit-1 downto 0);
          OperandB:     in std_logic_vector(Nbit-1 downto 0);
          OperationSel: in std_logic_vector(4-1 downto 0);
          ALUOut:       in std_logic_vector(Nbit-1 downto 0);
          );
end ProAlu;

architecture struct of ProAlu is

begin

----components used

--Logical operations component (T2 method)
component Logic is 
    generic ( Nbit: integer;
    );
	Port(A:	In	std_logic_vector(Nbit-1 downto 0); --input
		 B:	In	std_logic_vector(Nbit-1 downto 0); --input
		 S:	In	std_logic_vector(4-1 downto 0); --opcode for logic (know as selectN from lecture notes)
         C:  Out std_logic_vector(Nbit-1 downto 0)); --output    
end component;
			
--component used for shifting instructions (T2 methodology)
component Shifter is 
    generic (
        Nbit: integer;-- Nbit 32 bit
        );
	Port(A:	In	std_logic_vector(Nbit-1 downto 0); --input
		 B:	In	std_logic_vector(5-1 downto 0); --input bits shift , 5 o 6 bit?
         OP:  In  std_logic_vector(2-1 downto 0); -- input left or right
         S:  Out std_logic_vector(Nbit-1 downto 0)); --output 
    
end component;

--component used for multiplication instructions (T2 methodology (booth algo))
component BOOTHMUL is 
  generic(Nbit : integer := 16);
  port( A : in  std_logic_vector(Nbit-1 downto 0);
        B : in  std_logic_vector(Nbit-1 downto 0);
        P : out std_logic_vector(2*Nbit-1 downto 0)); 
end component;

--component used for addition and subtraction instructions (P4 sparse tree structure)
component p4_adder is
  generic (NBIT:integer;
           NBIT_PER_BLOCK: integer);
  port(A : in std_logic_vector(NBIT-1 downto 0);
       B : in std_logic_vector(NBIT-1 downto 0);
       Cin : in	std_logic;
       S : out std_logic_vector(NBIT-1 downto 0);
       Cout : out std_logic);
end component; 

--needed for the subtraction
component IV is
    Port (A:	In	std_logic;
		  Y:	Out	std_logic);
end component;

--comparatore forse da includere , per le istruzioni che chiedono di saltare al confronto di due valori di 2 operandi o semplici instruzioni di cmp

constant Nbit: integer := 32;

constant ANDop:       std_logic_vector(4-1 downto 0) := "1000";
constant NANDop:      std_logic_vector(4-1 downto 0) := "0111";
constant ORop:        std_logic_vector(4-1 downto 0) := "1110";
constant NORop:       std_logic_vector(4-1 downto 0) := "0001";
constant XORop:       std_logic_vector(4-1 downto 0) := "0110";
constant XNORop:      std_logic_vector(4-1 downto 0) := "1001";

signal resultAdd:       std_logic_vector(Nbit-1 downto 0);
signal cin4sub:         std_logic; --if 0, we do an addition if 1 we do a subtraction.
signal Bcomplement:     std_logic_vector(Nbit-1 downto 0);
signal intermediateB:   std_logic_vector(Nbit-1 downto 0);

signal resultLogic:     std_logic_vector(Nbit-1 downto 0);
signal LogicOp:         std_logic_vector(4-1 downto 0);

signal ShifterOp:       std_logic_vector(2-1 downto 0);
signal resultShifter:   std_logic_vector(Nbit-1 downto 0);

signal resultMul:       std_logic_vector(Nbit-1 downto 0);

begin

    Addition: p4_adder
    generic map(Nbit, 3)   --need to figure out what to put for nbit per block generic parameter
    port map(A => OperandA, B => intermediateB , Cin => cin4sub, S => resultAdd, open);
    
    BComplement : for i in 0 to Nbit-1 generate
    inverterI : iv
    port map( B(i), Bcomplement(i));
    end generate BComplement;

    LogicalStuff: Logic
    generic map(Nbit)
    port map(A => operandA, B => operandB, OperationSel => LogicOp, C => resultLogic);
    -- SHIFTER: B takes 5 LSBs, 
    Shifter: shifter
    generic map(Nbit)
    port map(A => OperandA, B => operandB(5-1 downto 0), OP => ShifterOp, S => resultShifter);

    Multiplication: BOOTHMUL
    generic map(Nbit/2) --i think that operands cant be greater then size 16 for the multiplication to make sense (since result has only 32 bits to be stored in)
    port map(A => OperandA, B => OperandB, P => resultMul);


    OpSelection: process(OperationSel, OperandB, resultAdd, resultLogic) 
    case OperationSel is
    begin
        when "0000" =>  -- ADD
        
        intermediateB <= OperandB; --we use the original B as second operand
        cin4sub <= '0';
        AluOut <= resultAdd;

        when "0001" =>  -- SUB

        intermediateB <= Bcomplement;
        cin4sub <= '1';
        AluOut <= resultAdd;

        when "0010" =>  -- AND

        LogicOp <= ANDop;  --dont forget, ANDOp is a constant seen above it is 1000.
        AluOut <= resultLogic;


        when "1110" =>  -- NAND

        LogicOp <= NANDop;
        AluOut <= resultLogic;

        when "0011" =>  -- OR

        LogicOp <= ORop;
        AluOut <= resultLogic;

        when "1010" =>  -- XOR

        LogicOp <= XORop;
        AluOut <= resultLogic;

        when "0110" =>  -- XNOR

        LogicOp <= XNORop;
        AluOut <= resultLogic;

        when "1001" =>  -- logical shift left

        ShifterOp <= "00";
        AluOut <= resultShifter; 

        when "0111" =>  -- logical shift right

        ShifterOp <= "01";
        AluOut <= resultShifter;

        when "1000" =>  -- Shift Right Arithmetic

        ShifterOp <= "10";
        AluOut <= resultShifter;

        -- MUL to be added

    end case;
    end process Opselection;
end struct;