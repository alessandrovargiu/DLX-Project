LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;

ENTITY CU_dlx IS
    GENERIC (
        MICROCODE_MEM_SIZE : INTEGER := 48; -- Microcode Memory Size
        FUNC_SIZE : INTEGER := 11; -- Func Field Size for R-Type Ops
        OP_CODE_SIZE : INTEGER := 6; -- Op Code Size
        CW_SIZE : INTEGER := 25 -- output signals of CU
    );
    PORT (   
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        IR_in : IN STD_LOGIC_VECTOR(Nbit - 1 DOWNTO 0);
        hzd_sig_jmp: in std_logic;
        hzd_sig_ctrl: in std_logic;
        hzd_sig_raw: in std_logic;
        decode_cwd : OUT STD_LOGIC_VECTOR(CW_SIZE-1 DOWNTO 0);
        execute_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-5 DOWNTO 0);
        memory_cwd : out STD_LOGIC_VECTOR (CW_SIZE-1-17 DOWNTO 0);
        wb_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-20 DOWNTO 0);
        IR_ID: OUT std_logic_vector(Nbit-1 downto 0);
        IR_EX: OUT std_logic_vector(Nbit-1 downto 0);
        IR_MEM: OUT std_logic_vector(Nbit-1 downto 0);
        IR_WB: OUT std_logic_vector(Nbit-1 downto 0)
    );
end entity;

ARCHITECTURE behavioral OF CU_dlx IS
        TYPE mem_array IS ARRAY (INTEGER RANGE 0 TO MICROCODE_MEM_SIZE - 1) OF STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0); 
        SIGNAL cw_mem : mem_array := (
            ADD_CWD, --0
            SUB_CWD, --1
            AND_CWD,--2
            OR_CWD,--3
            XOR_CWD,--4
            XNOR_CWD,--5
            NOR_CWD,--6
            NAND_CWD,--7
            SGE_CWD,--8
            SLE_CWD,--9
            SEQ_CWD,--10
            SNE_CWD,--11
            SLT_CWD,--12
            SGT_CWD,--13
            SRL_CWD,--14
            SLL_CWD,--15
            SRA_CWD,--16
            NOP_CWD,--17
            ADDI_CWD,--18
            SUBI_CWD,--19
            ANDI_CWD,--20
            ORI_CWD,--21
            XORI_CWD,--22
            XNORI_CWD,--23
            NORI_CWD,--24
            NANDI_CWD,--25
            SGEI_CWD,--26
            SLEI_CWD,--27
            SEQI_CWD,--28
            SNEI_CWD,--29
            SLTI_CWD,--30
            SGTI_CWD,--31
            SRLI_CWD,--32
            SLLI_CWD,--33
            SRAI_CWD,--34
            LDW_CWD,--35
            STW_CWD,--36
            JMP_CWD,--37
            JAL_CWD,--38
            BEQZ_CWD,--39
            BNEZ_CWD,--40
            SGEU_CWD,--41
            SGTU_CWD,--42
            SGEUI_CWD,--43
            SGTUI_CWD,--44
            ADDUI_CWD,--45
            SUBUI_CWD,--46
            JR_CWD --47
        );

        SIGNAL opcode_s : STD_LOGIC_VECTOR (OP_CODE_SIZE - 1 DOWNTO 0);
        SIGNAL func_s : STD_LOGIC_VECTOR (FUNC_SIZE - 1 DOWNTO 0);
        SIGNAL cw_s : STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0); 
        SIGNAL decode_cwd_s : STD_LOGIC_VECTOR(CW_SIZE-1 DOWNTO 0);
        SIGNAL execute_cwd_s : STD_LOGIC_VECTOR(CW_SIZE-1 - 5 DOWNTO 0);
        SIGNAL memory_cwd_s : STD_LOGIC_VECTOR(CW_SIZE-1 - 17 DOWNTO 0);
        signal wb_cwd_s: std_logic_vector(CW_SIZE-1 - 20 downto 0);
        signal IR_ID_s,IR_EX_s, IR_MEM_s, IR_WB_s: std_logic_vector(Nbit-1 downto 0);
        signal IR_ID_backup: std_logic_vector(CW_SIZE-1 downto 0);
        signal backup: std_logic;
        signal hzd_s: std_logic; 
        signal hzd1_s: std_logic;
        signal hzd2_s: std_logic;                     
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
                    ELSIF (func_s = RTYPE_SGEU) THEN
                        cw_s <= cw_mem(41); 
                    ELSIF (func_s = RTYPE_SGTU) THEN
                        cw_s <= cw_mem(42);
                    ELSE
                        cw_s <= cw_mem(17); --nop
                    END IF;
                ELSIF (opcode_s = NOP) THEN
                    cw_s <= cw_mem(17);
                ELSIF (opcode_s = ITYPE_ADDI1) THEN
                    cw_s <= cw_mem(18);
                ELSIF (opcode_s = ITYPE_ADDUI) THEN
                    cw_s <= cw_mem(45);
                ELSIF (opcode_s = ITYPE_SUBI1) THEN
                    cw_s <= cw_mem(19);
                ELSIF (opcode_s = ITYPE_SUBUI) THEN
                    cw_s <= cw_mem(46);
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
                ELSIF (opcode_s = ITYPE_SGEUI) THEN
                    cw_s <= cw_mem(43);
                ELSIF (opcode_s = ITYPE_SGTUI) THEN
                    cw_s <= cw_mem(44);
                ELSIF (opcode_s = ITYPE_JR ) THEN
                    cw_s <= cw_mem(47);

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
                        hzd1_s <= '0';
                        hzd2_s <= '0';
                        if(hzd_sig_jmp = '1') then
                            decode_cwd_s <= NOP_cwd;
                            IR_ID_s <= NOP_IR;
                            hzd1_s <= hzd_sig_jmp;
                        end if;

                        hzd_s <= '0';
                        
                        if(hzd_sig_ctrl = '1') then          --flush pipe
                            -- decode flush
                            decode_cwd_s <= NOP_cwd;
                            IR_ID_s <= NOP_IR;
                            -- EX flush
                            execute_cwd_s <= NOP_cwd(CW_SIZE-1-5 DOWNTO 0);
                            IR_EX_s <= NOP_IR;
                            hzd_s <= hzd_sig_ctrl;
                        end if;
                        -- extend stalls when pipe is flushed
                        if (hzd_s = '1') then
                            decode_cwd_s <= NOP_cwd;
                            IR_ID_s <= NOP_IR;
                            hzd_s <= '0';
                        end if;
                        if (hzd1_s = '1') then
                            decode_cwd_s <= NOP_cwd;
                            IR_ID_s <= NOP_IR;
                            hzd2_s <= '1';
                            hzd1_s <= '0';
                        end if;
                        if (hzd2_s = '1') then
                            decode_cwd_s <= NOP_cwd;
                            IR_ID_s <= NOP_IR;
                            hzd2_s <= '0';
                        end if;
                end if;
            end process;
            
END behavioral;
