library ieee;
use ieee.std_logic_1164.all;

package INSTR_CODES is

-- Control unit input sizes
    constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size

	-- R-Type instruction format :  | opcode | Rs1 | Rs2 | Rd | func |
	-- FUNC table
	constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";   
    constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";   
	constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";
	constant RTYPE_OR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=   "00000000011";
	constant RTYPE_SGE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";		-- set if greaterequal than
	constant RTYPE_SLE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000101";		-- set if lessequal than
	constant RTYPE_SEQ : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000101";		-- set if equal
	constant RTYPE_SNE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";		-- set if not equal
	constant RTYPE_SRL : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";		-- shift right logical
	constant RTYPE_SRA : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001000";		-- shift right arith
	constant RTYPE_SLL : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001001";		-- shift left logical
	constant RTYPE_XOR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001010";		
	constant RTYPE_SLT : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001011"; 		--set if lower than
	constant RTYPE_SGT : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001100";		--set if greater than
	 xnor nand nor ADDU SUBU
-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- R-type OPCODE
	constant NOP : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010"; 
-- I-Type instruction -> OPCODE field
    constant ITYPE_ADDI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SUBI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";
	constant ITYPE_ANDI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";
	constant ITYPE_ORI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "000101";
	--constant ITYPE_ADDI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";
	--constant ITYPE_SUBI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";
	--constant ITYPE_ANDI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";
	--constant ITYPE_ORI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "001001";
	constant ITYPE_BEQZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "001010";
	constant ITYPE_BNEZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "001011";
	constant ITYPE_LDW : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=    "001100";
	constant ITYPE_STW : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=	   "001101";
	constant ITYPE_XORI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "001110";
	constant ITYPE_SGEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "001111";
	constant ITYPE_SLEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010000";
	constant ITYPE_SLLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010001";
	constant ITYPE_SNEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010010";
	constant ITYPE_SRLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010011";
	constant ITYPE_SEQI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010100";
	constant ITYPE_SRAI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010101";
	constant ITYPE_SLTI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010110";
	constant ITYPE_SGTI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010111";
	-- J-Type instruction format: | opcode | value |
	constant JTYPE_JMP : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100000";
	constant JTYPE_JAL : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100001";

	--- CONTROL WORD

	--RTYPE
	--ADD
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111"; --MUX_SEL A 11 (dont care)
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011000000";
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--SUB
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011000100";
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--AND
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011000111"; --S0 S1 S2 S3
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	
	--OR
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011011111"; --S0 S1 S2 S3
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--XOR
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011011011"; --S0 S1 S2 S3
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--XNOR
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011100111"; --S0 S1 S2 S3
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--NOR
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011100011"; --S0 S1 S2 S3
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--NAND
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011111011"; --S0 S1 S2 S3
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--SGE
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011001110"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--SLE
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011100110"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--SEQ
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011000110"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;
--
	--SNE  (it's a SEQ with 0 as result)
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011000110"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--SLT
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011011110"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--SGT
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011010110"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--SRL
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011010101"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;
	--SLL
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011010001"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;
	--SRA
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1011011001"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--ITYPE

	--NOP
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1101000001"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--ADDI
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1101000000"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;
	-- DA FARE FROM QUA
	--
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1101000001"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;

	--
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant ADD_EXECUTE: std_logic_vector(9 downto 0) := "1101000001"; 
	constant ADD_MEMORY: std_logic_vector(4 downto 0) := "01000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB  ;





end INSTR_CODES;

