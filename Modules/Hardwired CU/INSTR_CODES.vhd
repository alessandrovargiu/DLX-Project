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
	constant RTYPE_SGE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";		-- set if greater than
	constant RTYPE_SLE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000101";		-- set if less than
	constant RTYPE_SLL : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000101";		-- shift left logical
	constant RTYPE_SNE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";		-- set if not equal
	constant RTYPE_SRL : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";		-- shift right logical
	constant RTYPE_XOR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001000";		

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

	-- J-Type instruction format: | opcode | value |
	constant JTYPE_JMP : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100000";
	constant JTYPE_JAL : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100001";


end INSTR_CODES;

