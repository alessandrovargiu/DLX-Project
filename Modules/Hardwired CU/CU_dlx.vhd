library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity CU_dlx is
    generic(
			--MICROCODE_MEM_SIZE :     integer := 19;  -- Microcode Memory Size
    		FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    		OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
			--CW_SIZE : integer := 13;				-- output signals of CU
			--ALU_SIZE : Integer := 2    --2 bits for 4 operations 0 1 2 3
			); 
    port(

        --Instr_wrd: IN std_logic_vector (totbit downto 0)    
        clk: IN std_logic;
        reset: IN std_logic;
        opcode : IN  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
        func  : IN  std_logic_vector(FUNC_SIZE - 1 downto 0);
        stall : IN std_logic;
        jump: IN std_logic;         
        --control_wrd: OUT std_logic_vector (totbit downto 0)

        --decode
        rf1: out std_logic; --read port A of register file
        rf2: out std_logic; --read port B of reg file
        en1: out std_logic; -- decode register??
        mux_sel: out std_logic: --to choose 16 o 26 bit (extender?)
        --execution
        s1 : out std_logic;               -- input selection of the first multiplexer (PC/A)
        s2 : out std_logic;               -- input selection of the second multiplexer (IMM/B)
        s3 : out std_logic;               -- input selection of the third multplexer   (Rt itype/ Rd rtype)
        en2: out std_logic;               -- exe regs
        alu: out std_logic_vector (1 downto 0);
        -- vedere hazard e pc

        --memory
        wm: out std_logic; -- enables the write-in of the memory
        en3: out std_logic; -- enables mem regs
        rm: out std_logic; -- enables the read-out of the memory
        wrf: out std_logic; --if writes in RF
        
        --Write back
        en4: out std_logic;  --write port rf
        en5: out std_logic;  --writeback regs
        s4: out std_logic;  -- ALU/MEM
        s5: out std_logic -- 1 if writes back on RF
    );
    architecture behavioral of CU_dlx is
        type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);  --rivedere size
          signal cw_mem : mem_array := (

          );
    
    signal opcode_s : std_logic_vector ( 6- 1 downto 0); 
    signal func_s : std_logic_vector (11 - 1 downto 0);
    signal cw_s   : std_logic_vector(CW_SIZE - 1 downto 0);   --entire control word
    signal cw1_s   : std_logic_vector(CW_SIZE - 1 - 4 downto 0); --controllare le dimensioni
    signal cw2_s   : std_logic_vector(CW_SIZE - 1 - 10 downto 0); 
    signal cw3_s   : std_logic_vector(CW_SIZE - 1 -14 downto 0); 


end CU_dlx;
