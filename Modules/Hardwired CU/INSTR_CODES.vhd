library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

package INSTR_CODES is

-- Control unit input sizes
    constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size

	-- R-Type instruction format :  | opcode | Rs1 | Rs2 | Rd | func |
	-- FUNC table
	constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100000";   
    constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100010";   
	constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100100";
	constant RTYPE_OR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=   "00000100101";
	constant RTYPE_SGE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101101";		-- set if greaterequal than
	constant RTYPE_SLE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101100";		-- set if lessequal than
	constant RTYPE_SEQ : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101000";		-- set if equal
	constant RTYPE_SNE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101001";		-- set if not equal
	constant RTYPE_SRL : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";		-- shift right logical
	constant RTYPE_SRA : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";		-- shift right arith
	constant RTYPE_SLL : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";		-- shift left logical
	constant RTYPE_XOR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100110";		
	constant RTYPE_SLT : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101010"; 		--set if lower than
	constant RTYPE_SGT : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101011";		--set if greater than
	constant RTYPE_XNOR : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000111111";
	constant RTYPE_NAND : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00001001010";
	constant RTYPE_NOR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00001001011";
	constant RTYPE_ADDU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100001";
	constant RTYPE_SUBU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100011";

	constant RTYPE_SGEU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000111101";
	constant RTYPE_SGTU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000111011";

-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- R-type OPCODE
	constant NOP : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010101"; 
	constant NOP_IR : std_logic_vector(Nbit-1 downto 0) := NOP & "00000000000000000000000000";
-- I-Type instruction -> OPCODE field
	-- I-Type instruction format :  | opcode | Rs1 | Rd | immediate |   
	constant ITYPE_ADDI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SUBI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";
	constant ITYPE_ANDI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";
	constant ITYPE_ORI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "001101";
	--constant ITYPE_ADDI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";
	--constant ITYPE_SUBI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";
	--constant ITYPE_ANDI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";
	--constant ITYPE_ORI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "001001";
	constant ITYPE_BEQZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "000100";
	constant ITYPE_BNEZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "000101";
	constant ITYPE_LDW : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=    "100011";
	constant ITYPE_STW : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=	   "101011";
	constant ITYPE_XORI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "001110";
	constant ITYPE_SGEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "011101";
	constant ITYPE_SLEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "011100";
	constant ITYPE_SLLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010100";
	constant ITYPE_SNEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "011001";
	constant ITYPE_SRLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010110";
	constant ITYPE_SEQI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "011000";
	constant ITYPE_SRAI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "010111";
	constant ITYPE_SLTI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "011010";
	constant ITYPE_SGTI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "011011";
	constant ITYPE_ADDUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";
	constant ITYPE_SUBUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";
	constant ITYPE_XNORI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011110";
	constant ITYPE_NORI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011111";
	constant ITYPE_NANDI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101010";

	constant ITYPE_SGEUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111101";
	constant ITYPE_SGTUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111011";


	-- J-Type instruction format: | opcode | value |
	constant JTYPE_JMP : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";
	constant JTYPE_JAL : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";

	--- CONTROL WORD

	--RTYPE
	--ADD
	constant ADD_DECODE : std_logic_vector(4 downto 0) := "11111"; --MUX_SEL A 11 (dont care)
	constant ADD_EXECUTE: std_logic_vector(11 downto 0) := "101100000000";
	constant ADD_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant ADD_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADD_CWD: std_logic_vector(24 downto 0) := ADD_DECODE &  ADD_EXECUTE & ADD_MEMORY & ADD_WB;

	--ADDU same cwd as ADD

	--SUB
	constant SUB_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SUB_EXECUTE: std_logic_vector(11 downto 0) := "101100010000";
	constant SUB_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SUB_WB: std_logic_vector(4 downto 0) := "11000";
	constant SUB_CWD: std_logic_vector(24 downto 0) := SUB_DECODE &  SUB_EXECUTE & SUB_MEMORY & SUB_WB;

	--SUBU same cwd as SUB

	--AND
	constant AND_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant AND_EXECUTE: std_logic_vector(11 downto 0) := "101110001100"; 
	constant AND_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant AND_WB: std_logic_vector(4 downto 0) := "11000";
	constant AND_CWD: std_logic_vector(24 downto 0) := AND_DECODE &  AND_EXECUTE & AND_MEMORY & AND_WB;
	

	
	--OR
	constant OR_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant OR_EXECUTE: std_logic_vector(11 downto 0) := "101111101100"; 
	constant OR_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant OR_WB: std_logic_vector(4 downto 0) := "11000";
	constant OR_CWD: std_logic_vector(24 downto 0) := OR_DECODE &  OR_EXECUTE & OR_MEMORY & OR_WB;

	--XOR
	constant XOR_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant XOR_EXECUTE: std_logic_vector(11 downto 0) := "101101101100"; 
	constant XOR_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant XOR_WB: std_logic_vector(4 downto 0) := "11000";
	constant XOR_CWD: std_logic_vector(24 downto 0) := XOR_DECODE & XOR_EXECUTE & XOR_MEMORY & XOR_WB;

	--XNOR
	constant XNOR_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant XNOR_EXECUTE: std_logic_vector(11 downto 0) := "101110011100"; 
	constant XNOR_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant XNOR_WB: std_logic_vector(4 downto 0) := "11000";
	constant XNOR_CWD: std_logic_vector(24 downto 0) := XNOR_DECODE & XNOR_EXECUTE & XNOR_MEMORY & XNOR_WB;

	--NOR
	constant NOR_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant NOR_EXECUTE: std_logic_vector(11 downto 0) := "101100011100"; 
	constant NOR_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant NOR_WB: std_logic_vector(4 downto 0) := "11000";
	constant NOR_CWD: std_logic_vector(24 downto 0) := NOR_DECODE &  NOR_EXECUTE & NOR_MEMORY & NOR_WB;

	--NAND
	constant NAND_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant NAND_EXECUTE: std_logic_vector(11 downto 0) := "101101111100"; 
	constant NAND_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant NAND_WB: std_logic_vector(4 downto 0) := "11000";
	constant NAND_CWD: std_logic_vector(24 downto 0) := NAND_DECODE &  NAND_EXECUTE & NAND_MEMORY & NAND_WB;

	--SGE
	constant SGE_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SGE_EXECUTE: std_logic_vector(11 downto 0) := "101100111000"; 
	constant SGE_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SGE_WB: std_logic_vector(4 downto 0) := "11000";
	constant SGE_CWD: std_logic_vector(24 downto 0) := SGE_DECODE &  SGE_EXECUTE & SGE_MEMORY & SGE_WB;

	--SLE
	constant SLE_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SLE_EXECUTE: std_logic_vector(11 downto 0) := "101110011000"; 
	constant SLE_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SLE_WB: std_logic_vector(4 downto 0) := "11000";
	constant SLE_CWD: std_logic_vector(24 downto 0) := SLE_DECODE &  SLE_EXECUTE & SLE_MEMORY & SLE_WB;

	--SEQ
	constant SEQ_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SEQ_EXECUTE: std_logic_vector(11 downto 0) := "101100011000"; 
	constant SEQ_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SEQ_WB: std_logic_vector(4 downto 0) := "11000";
	constant SEQ_CWD: std_logic_vector(24 downto 0) := SEQ_DECODE &  SEQ_EXECUTE & SEQ_MEMORY & SEQ_WB;
--
	--SNE  (it's a SEQ with 0 as result)
	constant SNE_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SNE_EXECUTE: std_logic_vector(11 downto 0) := "101110111000"; 
	constant SNE_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SNE_WB: std_logic_vector(4 downto 0) := "11000";
	constant SNE_CWD: std_logic_vector(24 downto 0) := SNE_DECODE &  SNE_EXECUTE & SNE_MEMORY & SNE_WB;

	--SLT 
	constant SLT_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SLT_EXECUTE: std_logic_vector(11 downto 0) := "101101111000"; 
	constant SLT_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SLT_WB: std_logic_vector(4 downto 0) := "11000";
	constant SLT_CWD: std_logic_vector(24 downto 0) := SLT_DECODE &  SLT_EXECUTE & SLT_MEMORY & SLT_WB;

	--SGT 
	constant SGT_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SGT_EXECUTE: std_logic_vector(11 downto 0) := "101101011000"; 
	constant SGT_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SGT_WB: std_logic_vector(4 downto 0) := "11000";
	constant SGT_CWD: std_logic_vector(24 downto 0) := SGT_DECODE &  SGT_EXECUTE & SGT_MEMORY & SGT_WB;

	--SGEU 
	constant SGEU_DECODE : std_logic_vector(4 downto 0) := "11111"; --last 2 bits dont care
	constant SGEU_EXECUTE: std_logic_vector(11 downto 0) := "101111011000"; 
	constant SGEU_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SGEU_WB: std_logic_vector(4 downto 0) := "11000";
	constant SGEU_CWD: std_logic_vector(24 downto 0) := SGEU_DECODE &  SGEU_EXECUTE & SGEU_MEMORY & SGEU_WB;

	--SGTU
	constant SGTU_DECODE : std_logic_vector(4 downto 0) := "11111"; --last 2 bits are dont care
	constant SGTU_EXECUTE: std_logic_vector(11 downto 0) := "101111111000"; 
	constant SGTU_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SGTU_WB: std_logic_vector(4 downto 0) := "11000";
	constant SGTU_CWD: std_logic_vector(24 downto 0) := SGTU_DECODE &  SGTU_EXECUTE & SGTU_MEMORY & SGTU_WB;

	--SRL
	constant SRL_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SRL_EXECUTE: std_logic_vector(11 downto 0) := "101101010100"; 
	constant SRL_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SRL_WB: std_logic_vector(4 downto 0) := "11000";
	constant SRL_CWD: std_logic_vector(24 downto 0) := SRL_DECODE &  SRL_EXECUTE & SRL_MEMORY & SRL_WB;
	--SLL
	constant SLL_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SLL_EXECUTE: std_logic_vector(11 downto 0) := "101101000100"; 
	constant SLL_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SLL_WB: std_logic_vector(4 downto 0) := "11000";
	constant SLL_CWD: std_logic_vector(24 downto 0) := SLL_DECODE &  SLL_EXECUTE & SLL_MEMORY & SLL_WB;
	--SRA
	constant SRA_DECODE : std_logic_vector(4 downto 0) := "11111";
	constant SRA_EXECUTE: std_logic_vector(11 downto 0) := "101101110100"; 
	constant SRA_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SRA_WB: std_logic_vector(4 downto 0) := "11000";
	constant SRA_CWD: std_logic_vector(24 downto 0) := SRA_DECODE &  SRA_EXECUTE & SRA_MEMORY & SRA_WB;

	--ITYPE

	--NOP
	constant NOP_DECODE : std_logic_vector(4 downto 0) := "10110";
	constant NOP_EXECUTE: std_logic_vector(11 downto 0) := "110100000000"; 
	constant NOP_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant NOP_WB: std_logic_vector(4 downto 0) := "10000";
	constant NOP_CWD: std_logic_vector(24 downto 0) := NOP_DECODE &  NOP_EXECUTE & NOP_MEMORY & NOP_WB;

	--ADDI
	constant ADDI_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant ADDI_EXECUTE: std_logic_vector(11 downto 0) := "110100000000"; 
	constant ADDI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant ADDI_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADDI_CWD: std_logic_vector(24 downto 0) := ADDI_DECODE &  ADDI_EXECUTE & ADDI_MEMORY & ADDI_WB;
	
	--ADDUI
	constant ADDUI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant ADDUI_EXECUTE: std_logic_vector(11 downto 0) := "110100000000"; 
	constant ADDUI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant ADDUI_WB: std_logic_vector(4 downto 0) := "11000";
	constant ADDUI_CWD: std_logic_vector(24 downto 0) := ADDUI_DECODE &  ADDUI_EXECUTE & ADDUI_MEMORY & ADDUI_WB;

	--SUBI
	constant SUBI_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant SUBI_EXECUTE: std_logic_vector(11 downto 0) := "110100010000"; 
	constant SUBI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SUBI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SUBI_CWD: std_logic_vector(24 downto 0) := SUBI_DECODE &  SUBI_EXECUTE & SUBI_MEMORY & SUBI_WB;

	--SUBUI
	constant SUBUI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant SUBUI_EXECUTE: std_logic_vector(11 downto 0) := "110100010000"; 
	constant SUBUI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SUBUI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SUBUI_CWD: std_logic_vector(24 downto 0) := SUBUI_DECODE &  SUBUI_EXECUTE & SUBUI_MEMORY & SUBUI_WB;

	--ANDI
	constant ANDI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant ANDI_EXECUTE: std_logic_vector(11 downto 0) := "110110001100"; 
	constant ANDI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant ANDI_WB: std_logic_vector(4 downto 0) := "11000";
	constant ANDI_CWD: std_logic_vector(24 downto 0) := ANDI_DECODE &  ANDI_EXECUTE & ANDI_MEMORY & ANDI_WB;

	--ORI
	constant ORI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant ORI_EXECUTE: std_logic_vector(11 downto 0) := "110111101100"; 
	constant ORI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant ORI_WB: std_logic_vector(4 downto 0) := "11000";
	constant ORI_CWD: std_logic_vector(24 downto 0) := ORI_DECODE &  ORI_EXECUTE & ORI_MEMORY & ORI_WB;

	--XORI
	constant XORI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant XORI_EXECUTE: std_logic_vector(11 downto 0) := "110101101100"; 
	constant XORI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant XORI_WB: std_logic_vector(4 downto 0) := "11000";
	constant XORI_CWD: std_logic_vector(24 downto 0) := XORI_DECODE &  XORI_EXECUTE & XORI_MEMORY & XORI_WB;

	--XNORI
	constant XNORI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant XNORI_EXECUTE: std_logic_vector(11 downto 0) := "110110011100"; 
	constant XNORI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant XNORI_WB: std_logic_vector(4 downto 0) := "11000";
	constant XNORI_CWD: std_logic_vector(24 downto 0) := XNORI_DECODE &  XNORI_EXECUTE & XNORI_MEMORY & XNORI_WB;

	--NORI
	constant NORI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant NORI_EXECUTE: std_logic_vector(11 downto 0) := "110100011100"; 
	constant NORI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant NORI_WB: std_logic_vector(4 downto 0) := "11000";
	constant NORI_CWD: std_logic_vector(24 downto 0) := NORI_DECODE &  NORI_EXECUTE & NORI_MEMORY & NORI_WB;  

	--NANDI
	constant NANDI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant NANDI_EXECUTE: std_logic_vector(11 downto 0) := "110101111100"; 
	constant NANDI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant NANDI_WB: std_logic_vector(4 downto 0) := "11000";
	constant NANDI_CWD: std_logic_vector(24 downto 0) := NANDI_DECODE &  NANDI_EXECUTE & NANDI_MEMORY & NANDI_WB;

	--SGEI
	constant SGEI_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant SGEI_EXECUTE: std_logic_vector(11 downto 0) := "110100111000"; 
	constant SGEI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SGEI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SGEI_CWD: std_logic_vector(24 downto 0) := SGEI_DECODE &  SGEI_EXECUTE & SGEI_MEMORY & SGEI_WB;

	--SLEI
	constant SLEI_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant SLEI_EXECUTE: std_logic_vector(11 downto 0) := "110110011000"; 
	constant SLEI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SLEI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SLEI_CWD: std_logic_vector(24 downto 0) := SLEI_DECODE &  SLEI_EXECUTE & SLEI_MEMORY & SLEI_WB;

	--SEQI
	constant SEQI_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant SEQI_EXECUTE: std_logic_vector(11 downto 0) := "110100011000"; 
	constant SEQI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SEQI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SEQI_CWD: std_logic_vector(24 downto 0) := SEQI_DECODE &  SEQI_EXECUTE & SEQI_MEMORY & SEQI_WB;

	--SNEI
	constant SNEI_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant SNEI_EXECUTE: std_logic_vector(11 downto 0) := "101110111000"; 
	constant SNEI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SNEI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SNEI_CWD: std_logic_vector(24 downto 0) := SNEI_DECODE &  SNEI_EXECUTE & SNEI_MEMORY & SNEI_WB;

	--SLTI
	constant SLTI_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant SLTI_EXECUTE: std_logic_vector(11 downto 0) := "110101111000"; 
	constant SLTI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SLTI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SLTI_CWD: std_logic_vector(24 downto 0) := SLTI_DECODE &  SLTI_EXECUTE & SLTI_MEMORY & SLTI_WB;

	--SGTI
	constant SGTI_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant SGTI_EXECUTE: std_logic_vector(11 downto 0) := "110101011000"; 
	constant SGTI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SGTI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SGTI_CWD: std_logic_vector(24 downto 0) := SGTI_DECODE &  SGTI_EXECUTE & SGTI_MEMORY & SGTI_WB;

	--SGEUI
	constant SGEUI_DECODE : std_logic_vector(4 downto 0) := "10100"; --
	constant SGEUI_EXECUTE: std_logic_vector(11 downto 0) := "110111011000"; 
	constant SGEUI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SGEUI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SGEUI_CWD: std_logic_vector(24 downto 0) := SGEUI_DECODE &  SGEUI_EXECUTE & SGEUI_MEMORY & SGEUI_WB;

	--SGTUI
	constant SGTUI_DECODE : std_logic_vector(4 downto 0) := "10100"; --
	constant SGTUI_EXECUTE: std_logic_vector(11 downto 0) := "110111111000"; 
	constant SGTUI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SGTUI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SGTUI_CWD: std_logic_vector(24 downto 0) := SGTUI_DECODE &  SGTUI_EXECUTE & SGTUI_MEMORY & SGTUI_WB;

	--SRLI
	constant SRLI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant SRLI_EXECUTE: std_logic_vector(11 downto 0) := "110101010100"; 
	constant SRLI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SRLI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SRLI_CWD: std_logic_vector(24 downto 0) := SRLI_DECODE &  SRLI_EXECUTE & SRLI_MEMORY & SRLI_WB;

	--SLLI
	constant SLLI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant SLLI_EXECUTE: std_logic_vector(11 downto 0) := "110101000100"; 
	constant SLLI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SLLI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SLLI_CWD: std_logic_vector(24 downto 0) := SLLI_DECODE &  SLLI_EXECUTE & SLLI_MEMORY & SLLI_WB;

	--SRAI
	constant SRAI_DECODE : std_logic_vector(4 downto 0) := "10100";
	constant SRAI_EXECUTE: std_logic_vector(11 downto 0) := "110101110100"; 
	constant SRAI_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant SRAI_WB: std_logic_vector(4 downto 0) := "11000";
	constant SRAI_CWD: std_logic_vector(24 downto 0) := SRAI_DECODE &  SRAI_EXECUTE & SRAI_MEMORY & SRAI_WB;

	--LDW
	constant LDW_DECODE : std_logic_vector(4 downto 0) := "10101"; -- 2-4 dont care
	constant LDW_EXECUTE: std_logic_vector(11 downto 0) := "110100000000"; --3 dontcare
	constant LDW_MEMORY: std_logic_vector(2 downto 0) := "111";
	constant LDW_WB: std_logic_vector(4 downto 0) := "11100";
	constant LDW_CWD: std_logic_vector(24 downto 0) := LDW_DECODE &  LDW_EXECUTE & LDW_MEMORY & LDW_WB;

	--STW
	constant STW_DECODE : std_logic_vector(4 downto 0) := "11101";
	constant STW_EXECUTE: std_logic_vector(11 downto 0) := "111100000000"; --3 dontcare
	constant STW_MEMORY: std_logic_vector(2 downto 0) := "010";
	constant STW_WB: std_logic_vector(4 downto 0) := "00000"; --3 4 5 dontcare
	constant STW_CWD: std_logic_vector(24 downto 0) := STW_DECODE &  STW_EXECUTE & STW_MEMORY & STW_WB;

	--BEQZ
	constant BEQZ_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant BEQZ_EXECUTE: std_logic_vector(11 downto 0) := "010100000011"; --3rd bit is dont care
	constant BEQZ_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant BEQZ_WB: std_logic_vector(4 downto 0) :=  "00000";
	constant BEQZ_CWD: std_logic_vector(24 downto 0) := BEQZ_DECODE &  BEQZ_EXECUTE & BEQZ_MEMORY & BEQZ_WB;


	--BNEZ
	constant BNEZ_DECODE : std_logic_vector(4 downto 0) := "10101";
	constant BNEZ_EXECUTE: std_logic_vector(11 downto 0) := "010100000010"; --3rd bit is dont care
	constant BNEZ_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant BNEZ_WB: std_logic_vector(4 downto 0) :=  "00000";
	constant BNEZ_CWD: std_logic_vector(24 downto 0) := BNEZ_DECODE &  BNEZ_EXECUTE & BNEZ_MEMORY & BNEZ_WB;



	--JTYPE

	--JMP
	constant JMP_DECODE : std_logic_vector(4 downto 0) := "00111"; 
	constant JMP_EXECUTE: std_logic_vector(11 downto 0) := "010100000001"; --s3 dont care
	constant JMP_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant JMP_WB: std_logic_vector(4 downto 0) := "00000";
	constant JMP_CWD: std_logic_vector(24 downto 0) := JMP_DECODE &  JMP_EXECUTE & JMP_MEMORY & JMP_WB;

	--JAL
	constant JAL_DECODE : std_logic_vector(4 downto 0) := "00111";
	constant JAL_EXECUTE: std_logic_vector(11 downto 0) := "011100000001"; 
	constant JAL_MEMORY: std_logic_vector(2 downto 0) := "000";
	constant JAL_WB: std_logic_vector(4 downto 0) := "11111"; --s4 dont care
	constant JAL_CWD: std_logic_vector(24 downto 0) := JAL_DECODE &  JAL_EXECUTE & JAL_MEMORY & JAL_WB;

	


end INSTR_CODES;

