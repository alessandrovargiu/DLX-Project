LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;

ENTITY CU_dlx IS
    GENERIC (
        MICROCODE_MEM_SIZE : INTEGER := 41; -- Microcode Memory Size
        FUNC_SIZE : INTEGER := 11; -- Func Field Size for R-Type Ops
        OP_CODE_SIZE : INTEGER := 6; -- Op Code Size
        CW_SIZE : INTEGER := 25 -- output signals of CU
        --ALU_SIZE : Integer := 2    --2 bits for 4 operations 0 1 2 3
    );
    PORT (

        --Instr_wrd: IN std_logic_vector (totbit downto 0)    
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        --pc_sel: OUT STD_LOGIC;
        -- opcode : IN  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
        --func  : IN  std_logic_vector(FUNC_SIZE - 1 downto 0);
        IR_in : IN STD_LOGIC_VECTOR(Nbit - 1 DOWNTO 0);
        hzd_sig_jmp: in std_logic;
        hzd_sig_ctrl: in std_logic;
        hzd_sig_raw: in std_logic;
        --hzd_sig_raw_2clk: in std_logic;
        --stall : IN STD_LOGIC;
        --jump : IN STD_LOGIC;
        --control_wrd: OUT std_logic_vector (totbit downto 0)

        decode_cwd : OUT STD_LOGIC_VECTOR(CW_SIZE-1 DOWNTO 0);
        execute_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-5 DOWNTO 0);
        memory_cwd : out STD_LOGIC_VECTOR (CW_SIZE-1-17 DOWNTO 0);
        wb_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-20 DOWNTO 0);
        IR_ID: OUT std_logic_vector(Nbit-1 downto 0);
        IR_EX: OUT std_logic_vector(Nbit-1 downto 0);
        IR_MEM: OUT std_logic_vector(Nbit-1 downto 0);
        IR_WB: OUT std_logic_vector(Nbit-1 downto 0)
        --decode
        --rf1: out std_logic; --read port A of register file
        --rf2: out std_logic; --read port B of reg file
        --en1: out std_logic; -- enables decode pipeline reg and reg file
        --mux_sel: out std_logic_vector (1 downto 0): --to choose 16 o 26 bit extender to 32

        --execution
        --s1 : out std_logic;               -- input selection of the first multiplexer (PC+4/A)
        --s2 : out std_logic;               -- input selection of the second multiplexer (IMM/B)
        --s3 : out std_logic;               -- input selection of the third multplexer   (Rt itype/ Rd rtype) if address is 15-19 Rtype o Itype 10-14
        --en2: out std_logic;               -- exe pipe regs
        --alu: out std_logic_vector (5 downto 0); -- da vedere in base a ALU vera

        -- vedere hazard e pc

        --memory
        -- wm: out std_logic; -- enables the write-in of the memory
        --en3: out std_logic; -- enables mem regs and datamemory
        --rm: out std_logic; -- enables the read-out of the memory
        --j_en: out std_logic_vector (1 downto 0);
        --wrf: out std_logic; --if writes in RF

        --Write back
        -- wf1: out std_logic;  --write port rf
        -- en4: out std_logic;  --writeback regs - rf 
        --s4: out std_logic;  -- ALU/MEM
        --s5: out std_logic -- VAL/PC+4
        --mux_sel1: out std_logic --address rf for jump and link
    );
end entity;

ARCHITECTURE behavioral OF CU_dlx IS
        TYPE mem_array IS ARRAY (INTEGER RANGE 0 TO MICROCODE_MEM_SIZE - 1) OF STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0); --rivedere size
        SIGNAL cw_mem : mem_array := (
            ADD_CWD,
            SUB_CWD,
            AND_CWD,
            OR_CWD,
            XOR_CWD,
            XNOR_CWD,
            NOR_CWD,
            NAND_CWD,
            SGE_CWD,
            SLE_CWD,
            SEQ_CWD,
            SNE_CWD,
            SLT_CWD,
            SGT_CWD,
            SRL_CWD,
            SLL_CWD,
            SRA_CWD,
            NOP_CWD,
            ADDI_CWD,
            --ADDUI_CWD,
            SUBI_CWD,
            --SUBUI_CWD,
            ANDI_CWD,
            ORI_CWD,
            XORI_CWD,
            XNORI_CWD,
            NORI_CWD,
            NANDI_CWD,
            SGEI_CWD,
            SLEI_CWD,
            SEQI_CWD,
            SNEI_CWD,
            SLTI_CWD,
            SGTI_CWD,
            SRLI_CWD,
            SLLI_CWD,
            SRAI_CWD,
            LDW_CWD,
            STW_CWD,
            JMP_CWD,
            JAL_CWD,
            BEQZ_CWD,
            BNEZ_CWD
        );

        SIGNAL opcode_s : STD_LOGIC_VECTOR (OP_CODE_SIZE - 1 DOWNTO 0);
        SIGNAL func_s : STD_LOGIC_VECTOR (FUNC_SIZE - 1 DOWNTO 0);
        SIGNAL cw_s : STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0); --entire control word
        --signal cw1_s   : std_logic_vector(CW_SIZE - 1 - 4 downto 0); --controllare le dimensioni
        SIGNAL decode_cwd_s : STD_LOGIC_VECTOR(CW_SIZE-1 DOWNTO 0);
        SIGNAL execute_cwd_s : STD_LOGIC_VECTOR(CW_SIZE-1 - 5 DOWNTO 0);
        SIGNAL memory_cwd_s : STD_LOGIC_VECTOR(CW_SIZE-1 - 17 DOWNTO 0);
        signal wb_cwd_s: std_logic_vector(CW_SIZE-1 - 20 downto 0);
        signal IR_ID_s,IR_EX_s, IR_MEM_s, IR_WB_s: std_logic_vector(Nbit-1 downto 0);
        -- this signal is used to save the stalled instruction when hazard is present
        signal IR_ID_backup: std_logic_vector(CW_SIZE-1 downto 0);
        -- 1 if returning from stall cycle, 0 normal execution
        signal backup: std_logic;
        signal hzd_s: std_logic;                           
BEGIN
        PROCESS (IR_IN)
        BEGIN
            IF (IR_in(31 DOWNTO 26) = "000000") THEN
                opcode_s <= "000000";
                func_s <= IR_in(10 DOWNTO 0);
            ELSE
                opcode_s <= IR_in(31 DOWNTO 26);
                func_s <= "00000000000";
            END IF;
        END PROCESS;

        PROCESS (reset, opcode_s, func_s)
        BEGIN
            IF reset = '1' THEN
                cw_s <= cw_mem(17); -- nop
            ELSE
                IF (opcode_s = "000000") THEN
                    IF (func_s = RTYPE_ADD) THEN
                        cw_s <= cw_mem(0);
                    ELSIF (func_s = RTYPE_SUB) THEN
                        cw_s <= cw_mem(1);
                    ELSIF (func_s = RTYPE_AND) THEN
                        cw_s <= cw_mem(2);
                    ELSIF (func_s = RTYPE_OR) THEN
                        cw_s <= cw_mem(3);
                    ELSIF (func_s = RTYPE_XOR) THEN
                        cw_s <= cw_mem(4);
                    ELSIF (func_s = RTYPE_XNOR) THEN
                        cw_s <= cw_mem(5);
                    ELSIF (func_s = RTYPE_NOR) THEN
                        cw_s <= cw_mem(6);
                    ELSIF (func_s = RTYPE_NAND) THEN
                        cw_s <= cw_mem(7);
                    ELSIF (func_s = RTYPE_SGE) THEN
                        cw_s <= cw_mem(8);
                    ELSIF (func_s = RTYPE_SLE) THEN
                        cw_s <= cw_mem(9);
                    ELSIF (func_s = RTYPE_SEQ) THEN
                        cw_s <= cw_mem(10);
                    ELSIF (func_s = RTYPE_SNE) THEN
                        cw_s <= cw_mem(11);
                     ELSIF (func_s = RTYPE_SLT) THEN
                        cw_s <= cw_mem(12);
                    ELSIF (func_s = RTYPE_SGT) THEN
                        cw_s <= cw_mem(13);
                    ELSIF (func_s = RTYPE_SRL) THEN
                        cw_s <= cw_mem(14);
                    ELSIF (func_s = RTYPE_SLL) THEN
                        cw_s <= cw_mem(15);
                    ELSIF (func_s = RTYPE_SRA) THEN
                        cw_s <= cw_mem(16);
                    ELSIF (func_s = RTYPE_ADDU) THEN
                        cw_s <= cw_mem(0);
                    ELSIF (func_s = RTYPE_SUBU) THEN
                        cw_s <= cw_mem(1);
                    ELSE
                        cw_s <= cw_mem(17); --nop
                    END IF;
                ELSIF (opcode_s = NOP) THEN
                    cw_s <= cw_mem(17);
                ELSIF (opcode_s = ITYPE_ADDI1) THEN
                    cw_s <= cw_mem(18);
                ELSIF (opcode_s = ITYPE_ADDUI) THEN
                    cw_s <= cw_mem(18);
                ELSIF (opcode_s = ITYPE_SUBI1) THEN
                    cw_s <= cw_mem(19);
                ELSIF (opcode_s = ITYPE_SUBUI) THEN
                    cw_s <= cw_mem(19);
                ELSIF (opcode_s = ITYPE_ANDI1) THEN
                    cw_s <= cw_mem(20);
                ELSIF (opcode_s = ITYPE_ORI1) THEN
                    cw_s <= cw_mem(21);
                ELSIF (opcode_s = ITYPE_XORI) THEN
                    cw_s <= cw_mem(22);
                ELSIF (opcode_s = ITYPE_XNORI) THEN
                    cw_s <= cw_mem(23);
                ELSIF (opcode_s = ITYPE_NORI) THEN
                    cw_s <= cw_mem(24);
                ELSIF (opcode_s = ITYPE_NANDI) THEN
                    cw_s <= cw_mem(25);
                ELSIF (opcode_s = ITYPE_SGEI) THEN
                    cw_s <= cw_mem(26);
                ELSIF (opcode_s = ITYPE_SLEI) THEN
                    cw_s <= cw_mem(27);
                ELSIF (opcode_s = ITYPE_SEQI) THEN
                    cw_s <= cw_mem(28);
                ELSIF (opcode_s = ITYPE_SNEI) THEN
                    cw_s <= cw_mem(29);
                ELSIF (opcode_s = ITYPE_SLTI) THEN
                    cw_s <= cw_mem(30);
                  ELSIF (opcode_s = ITYPE_SGTI) THEN
                    cw_s <= cw_mem(31);
                ELSIF (opcode_s = ITYPE_SRLI) THEN
                    cw_s <= cw_mem(32);
                ELSIF (opcode_s = ITYPE_SLLI) THEN
                    cw_s <= cw_mem(33);
                ELSIF (opcode_s = ITYPE_SRAI) THEN
                    cw_s <= cw_mem(34);
                ELSIF (opcode_s = ITYPE_LDW) THEN
                    cw_s <= cw_mem(35);
                ELSIF (opcode_s = ITYPE_STW) THEN
                    cw_s <= cw_mem(36);
                ELSIF (opcode_s = JTYPE_JMP) THEN
                    cw_s <= cw_mem(37);
                ELSIF (opcode_s = JTYPE_JAL) THEN
                    cw_s <= cw_mem(38);
               ELSIF (opcode_s = ITYPE_BEQZ) THEN
                    cw_s <= cw_mem(39);
               ELSIF (opcode_s = ITYPE_BNEZ) THEN
                    cw_s <= cw_mem(40);
                ELSE
                    cw_s <= cw_mem(17); --nop
                END IF;
            end if;
            END PROCESS;

            decode_cwd <= decode_cwd_s;
            execute_cwd <= execute_cwd_s;
            memory_cwd <= memory_cwd_s;
            wb_cwd <= wb_cwd_s;

            IR_ID <= IR_ID_s;
            IR_EX <= IR_EX_s;
            IR_MEM <= IR_MEM_s;
            IR_WB <= IR_WB_s;
            -- PIPELINE PROCESS --
            -- introduce NOP in decode stage when hazard --
            -- proibits PC from incrementing --
            process(CLK, reset)
	        begin
                if(reset = '1') then
                    IR_ID_s <= NOP_IR;
                    IR_EX_s <= NOP_IR;
                    IR_MEM_s <= NOP_IR;
                    IR_WB_s <= NOP_IR;
                elsif(rising_edge(clk)) then
                        decode_cwd_s <= cw_s(CW_SIZE-1 DOWNTO 0);
		                execute_cwd_s <= decode_cwd_s(CW_SIZE - 1 - 5 DOWNTO 0);
                        memory_cwd_s <= execute_cwd_s(CW_SIZE - 1 - 17 DOWNTO 0);
                        wb_cwd_s <= memory_cwd_s(CW_SIZE - 1 - 20 DOWNTO 0);              
                    
                        IR_ID_s <= IR_in;
                        IR_EX_s <= IR_ID_s;
                        IR_MEM_s <= IR_EX_s;               
                        IR_WB_s <= IR_MEM_s;

                        if(hzd_sig_raw = '1') then
                            decode_cwd_s <= decode_cwd_s;             -- instr. causing HZD stays in decode
                            IR_ID_s <= IR_ID_s;                         --
                            execute_cwd_s <= NOP_cwd(CW_SIZE-1-5 DOWNTO 0);
                            IR_EX_s <= NOP_IR;
                        end if;
                        
                        if(hzd_sig_jmp = '1') then
                            decode_cwd_s <= NOP_cwd;
                            IR_ID_s <= NOP_IR;
                        end if;
                        if(hzd_sig_ctrl = '1') then          --flush pipe
                            -- decode flush
                            decode_cwd_s <= NOP_cwd;
                            IR_ID_s <= NOP_IR;
                            -- EX flush
                            execute_cwd_s <= NOP_cwd(CW_SIZE-1-5 DOWNTO 0);
                            IR_EX_s <= NOP_IR;
                            hzd_s <= hzd_sig_ctrl;
                        end if;
                        if (hzd_s = '1') then
                            decode_cwd_s <= NOP_cwd;
                            IR_ID_s <= NOP_IR;
                            hzd_s <= '0';
                        end if;
                end if;
            end process;
            
END behavioral;