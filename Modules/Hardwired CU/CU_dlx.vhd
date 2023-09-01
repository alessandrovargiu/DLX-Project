library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity CU_dlx is
    generic(
			MICROCODE_MEM_SIZE :     integer := 41;  -- Microcode Memory Size
    		FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    		OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
			CW_SIZE : integer := 25;				-- output signals of CU
			--ALU_SIZE : Integer := 2    --2 bits for 4 operations 0 1 2 3
			); 
    port(

        --Instr_wrd: IN std_logic_vector (totbit downto 0)    
        clk: IN std_logic;
        reset: IN std_logic;
       -- opcode : IN  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
        --func  : IN  std_logic_vector(FUNC_SIZE - 1 downto 0);
        IR_in: IN std_logic_vector(Nbit-1 downto 0);

        stall : IN std_logic;
        jump: IN std_logic;         
        --control_wrd: OUT std_logic_vector (totbit downto 0)

        decode_cwd: Out std_logic_vector(4 downto 0);
        execute_cwd: std_logic_vector (9 downto 0);
        memory_cwd: std_logic_vector (4 downto 0);
        wb_cwd: Out std_logic_vector (4 downto 0);

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
    architecture behavioral of CU_dlx is
        type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);  --rivedere size
          signal cw_mem : mem_array := (
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
                ADDUI_CWD,
                SUBI_CWD,
                SUBUI_CWD,
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
                JAL_CWD
            



          );
    
    signal opcode_s : std_logic_vector ( OP_CODE_SIZE- 1 downto 0); 
    signal func_s : std_logic_vector (FUNC_SIZE - 1 downto 0);
    signal cw_s   : std_logic_vector(CW_SIZE - 1 downto 0);   --entire control word
    --signal cw1_s   : std_logic_vector(CW_SIZE - 1 - 4 downto 0); --controllare le dimensioni
    signal cw2_s   : std_logic_vector(CW_SIZE - 1 - 4 downto 0); 
    signal cw3_s   : std_logic_vector(CW_SIZE - 1 -14 downto 0);
    signal cw4_s   : std_logic_vector(CW_SIZE - 1 -19 downto 0);


    begin
    process(IR_IN)
        begin
        if(IR_in(31 downto 26) == "000000") then
            opcode_s <= "000000";
            func_s <= IR_in(10 downto 0);
        else
            opcode_s <= IR_in(31 downto 26);
            func_s <= "00000000000";
        end if;
    end process;

    process(rst,opcode_s,func_s)
        begin
            if rst = '1' then
                cw_s<=cw_mem(19); -- nop
            else
                if (opcode_s="000000") then
                    if (func_s = RTYPE_ADD) then
                        cw_s<=cw_mem(0);
                    elsif (func_s = RTYPE_SUB) then
                        cw_s<=cw_mem(1);
                        elsif (func_s = RTYPE_AND) then
                            cw_s<=cw_mem(2);
                            elsif (func_s = RTYPE_OR) then
                                cw_s<=cw_mem(3);
                                elsif (func_s = RTYPE_SGE) then
                                    cw_s<=cw_mem(4);
                                    elsif (func_s = RTYPE_SLE) then
                                        cw_s<=cw_mem(5);
                                        elsif (func_s = RTYPE_SEQ) then
                                            cw_s<=cw_mem(6);
                                            elsif (func_s = RTYPE_SNE) then
                                                cw_s<=cw_mem(7);
                                                elsif (func_s = RTYPE_SRL) then
                                                    cw_s<=cw_mem(8);
                                                    elsif (func_s = RTYPE_SRA) then
                                                        cw_s<=cw_mem(9);
                                                        elsif (func_s = RTYPE_SLL) then
                                                            cw_s<=cw_mem(10);
                                                            elsif (func_s = RTYPE_XOR) then
                                                                cw_s<=cw_mem(11);
                                                                elsif (func_s = RTYPE_SLT) then
                                                                    cw_s<=cw_mem(12);
                                                                    elsif (func_s = RTYPE_SGT) then
                                                                        cw_s<=cw_mem(13);
                                                                        elsif (func_s = RTYPE_XNOR) then
                                                                            cw_s<=cw_mem(14);
                                                                            elsif (func_s = RTYPE_NAND) then
                                                                                cw_s<=cw_mem(15);
                                                                                elsif (func_s = RTYPE_NOR) then
                                                                                    cw_s<=cw_mem(16);
                                                                                    elsif (func_s = RTYPE_ADDU) then
                                                                                        cw_s<=cw_mem(17);
                                                                                        elsif (func_s = RTYPE_SUBU) then
                                                                                            cw_s<=cw_mem(18);
                                                                                        else
                                                                                            cw_s<=cw_mem(19); --nop
                                                                                        end if ;
                                                                                        elsif(opcode_s = NOP ) then
                                                                                            cw_s<=cw_mem(19); 
                                                                                            elsif(opcode_s = ITYPE_ADDI1 ) then
                                                                                                cw_s<=cw_mem(20); 
                                                                                                elsif(opcode_s = ITYPE_SUBI1 ) then
                                                                                                    cw_s<=cw_mem(21); 
                                                                                                    elsif(opcode_s = ITYPE_ANDI1 ) then
                                                                                                        cw_s<=cw_mem(22); 
                                                                                                        elsif(opcode_s = ITYPE_ORI1 ) then
                                                                                                            cw_s<=cw_mem(23); 
                                                                                                            elsif(opcode_s = ITYPE_BEQZ ) then
                                                                                                                cw_s<=cw_mem(24); 
                                                                                                                elsif(opcode_s = ITYPE_BNEZ ) then
                                                                                                                    cw_s<=cw_mem(25); 
                                                                                                                    elsif(opcode_s = ITYPE_LDW ) then
                                                                                                                        cw_s<=cw_mem(26);
                                                                                                                        elsif(opcode_s = ITYPE_XORI ) then
                                                                                                                            cw_s<=cw_mem(27);
                                                                                                                            elsif(opcode_s = ITYPE_SGEI ) then
                                                                                                                                cw_s<=cw_mem(28);
                                                                                                                                elsif(opcode_s = ITYPE_SLEI ) then
                                                                                                                                    cw_s<=cw_mem(29);
                                                                                                                                    elsif(opcode_s = ITYPE_SLLI ) then
                                                                                                                                        cw_s<=cw_mem(30);
                                                                                                                                        elsif(opcode_s = ITYPE_SNEI ) then
                                                                                                                                            cw_s<=cw_mem(31);
                                                                                                                                            elsif(opcode_s = ITYPE_SRLI ) then
                                                                                                                                                cw_s<=cw_mem(32);
                                                                                                                                                elsif(opcode_s = ITYPE_SEQI ) then
                                                                                                                                                    cw_s<=cw_mem(33);
                                                                                                                                                    elsif(opcode_s = ITYPE_SRAI ) then
                                                                                                                                                        cw_s<=cw_mem(34);
                                                                                                                                                        elsif(opcode_s = ITYPE_SLTI ) then
                                                                                                                                                            cw_s<=cw_mem(35);
                                                                                                                                                            elsif(opcode_s = ITYPE_SGTI ) then
                                                                                                                                                                cw_s<=cw_mem(36);
                                                                                                                                                                elsif(opcode_s = ITYPE_ADDUI ) then
                                                                                                                                                                    cw_s<=cw_mem(37);
                                                                                                                                                                    elsif(opcode_s = ITYPE_SUBUI ) then
                                                                                                                                                                        cw_s<=cw_mem(38);
                                                                                                                                                                        elsif(opcode_s = JTYPE_JMP ) then
                                                                                                                                                                            cw_s<=cw_mem(39);
                                                                                                                                                                            elsif(opcode_s = JTYPE_JAL ) then
                                                                                                                                                                                cw_s<=cw_mem(40);
                                                                                                                                                                                else
                                                                                                                                                                                    cw_s<=cw_mem(19); --nop
                                                                                                                                                                                end if
                                                                                            end process;                                                                                    
                                                                                                                                                                                process(cw_s,clk)
                                                                                                                                                                                    begin
                                                                                                                                                                                        --reset messo prima da capire se giusto
                                                                                                                                                                                        if Clk'event and Clk = '1' then
                                                                                                                                                                                            decode_cwd <= cw_s(CW_SIZE - 1 downto 0);
                                                                                                                                                                                            execute_cwd <= decode_cwd(CW_SIZE - 1 - 5 downto 0);
                                                                                                                                                                                            memory_cwd <= execute_cwd(CW_SIZE - 1 - 15 downto 0);
                                                                                                                                                                                            wb_cwd <= memory_cwd(CW_SIZE - 1- 20 downto 0);
                                                                                                                                                                                        end if 
                                                                                                                                                                                end process




                                                                                                                                                                            
                                                                                                                                                                            


                                                                                            
                                                                                        
                                                                                            
                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                        
                    


                







end CU_dlx;
