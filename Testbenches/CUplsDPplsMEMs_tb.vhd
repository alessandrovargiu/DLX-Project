library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
--use work.myTypes.all;
USE work.INSTR_CODES.ALL;

entity dpTestWithIram is
end dpTestWithIram;

architecture TESTPROVA of dpTestWithIram is

    constant Nbit: integer := 32;
    constant controlNbit: integer := 25;
    constant addressNbit: integer := 32; --number of bits used by the addresses of the instruction memory
    constant CW_SIZE : INTEGER := 25;

    constant CWNbitsID: integer  :=5;
    constant CWNbitsEX: integer  :=12;
    constant CWNbitsMEM: integer :=3;
    constant CWNbitsWB: integer  :=5;

    constant CWIdBitsADDI: std_logic_vector(CWNBitsID-1 downto 0) := "10101" ;
    constant CWExBitsADDI: std_logic_vector(CWNBitsEX-1 downto 0) := "110100000000";
    constant CWMemBitsADDI: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsADDI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsSUBI: std_logic_vector(CWNBitsID-1 downto 0) := "10101";
    constant CWExBitsSUBI: std_logic_vector(CWNBitsEX-1 downto 0) := "110100010000";
    constant CWMemBitsSUBI: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsSUBI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsORI: std_logic_vector(CWNBitsID-1 downto 0) := "10100";
    constant CWExBitsORI: std_logic_vector(CWNBitsEX-1 downto 0) := "110111101100";
    constant CWMemBitsORI: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsORI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsADD: std_logic_vector(CWNBitsID-1 downto 0) := "11111";
    constant CWExBitsADD: std_logic_vector(CWNBitsEX-1 downto 0) := "101100000000";
    constant CWMemBitsADD: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsADD: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWidBitsBEQZ: std_logic_vector(CWNBitsID-1 downto 0) := "10101";
    constant CWexBitsBEQZ: std_logic_vector(CWNBitsEX-1 downto 0) := "010100000011"; --3rd bit is dont care
    constant CWmemBitsBEQZ: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWwbBitsBEQZ: std_logic_vector(CWNbitsWB-1 downto 0) := "00000";

    constant CWidBitsBNEZ: std_logic_vector(CWNBitsID-1 downto 0) := "10101";
    constant CWexBitsBNEZ: std_logic_vector(CWNBitsEX-1 downto 0) := "010100000010"; --3rd bit is dont care
    constant CWmemBitsBNEZ: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWwbBitsBNEZ: std_logic_vector(CWNbitsWB-1 downto 0) := "00000";

    --JAL
	constant JAL_DECODE : std_logic_vector(4 downto 0) := "00111";
	constant JAL_EXECUTE: std_logic_vector(11 downto 0) := "011100000001"; 
	constant JAL_MEMORY: std_logic_vector(2 downto 0) := "010";
	constant JAL_WB: std_logic_vector(4 downto 0) := "11111"; --s4 dont care


    component BasicDP is
    Generic( NbitMem: integer;
             controlNbit: integer;
             addressNbit: integer );
    port(   Clk :        in std_logic;
            rst :        in std_logic;

            fromHU:      in std_logic;
            enable:      in std_logic;
            IMdata:      in std_logic_vector(Nbit-1 downto 0); --input from iram
            controlWord: in std_logic_vector(controlNbit-1 downto 0);
            DMdataIN:    in std_logic_vector(Nbit - 1 downto 0); --input from DMEM in case of Load inst

            IMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMdataOUT:   out std_logic_vector(Nbit-1 downto 0) -- output which goes to DMEM in case of Store inst
    );
end component;

component CU_dlx IS
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
        
    );
end component;

--    component CUbasic IS
--    GENERIC (
--        MICROCODE_MEM_SIZE : INTEGER := 41; -- Microcode Memory Size
--      FUNC_SIZE : INTEGER := 11; -- Func Field Size for R-Type Ops
--        OP_CODE_SIZE : INTEGER := 6; -- Op Code Size
--        CW_SIZE : INTEGER := 25 -- output signals of CU
--    );
--    PORT (    
--        clk : IN STD_LOGIC;
--        reset : IN STD_LOGIC;

--        IR_in : IN STD_LOGIC_VECTOR(Nbit - 1 DOWNTO 0);

--        decode_cwd : OUT STD_LOGIC_VECTOR(CW_SIZE-1 DOWNTO 0);
--        execute_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-5 DOWNTO 0);
--        memory_cwd : out STD_LOGIC_VECTOR (CW_SIZE-1-17 DOWNTO 0);
--        wb_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-20 DOWNTO 0);
--        controlWordOut: out std_logic_vector(CW_size - 1 downto 0)
--    );
--end component;

    component IRAM is
        generic (
            N: integer ;
            M: integer 
        );
        port(
            clk: in std_logic;
            rst: in std_logic;                            -- active low
            I_ADDR : in std_logic_vector(N-1 downto 0);     -- dimensions to be specified     
            I_DATA : out std_logic_vector(M-1 downto 0);
            ready : out std_logic                         -- active high
        );
    end component;

    component DRAM is
    generic (
        W: integer := 32;
        N: integer := 32
    );
    port(
        clk: in std_logic;
        rst: in std_logic;                            -- active low
        EN: in std_logic;
        RW: in std_logic;                             -- 1 - read, 0 - write
        ADDR: in std_logic_vector(W-1 downto 0);          
        DATA_IN: in std_logic_vector(N-1 downto 0);
        DATA_OUT: out std_logic_vector(N-1 downto 0);
        ready : out std_logic                         -- active high
    );
    end component;

    signal Clock: std_logic := '0';
    signal Reset: std_logic := '1';
    signal enable_i: std_logic ;
    signal fromHU_i: std_logic := '0';
    signal readyIRAM_i: std_logic; --output signal of the Iram
    signal readyDRAM_i: std_logic; --output bit from DRAM
    signal RW_i: std_logic;

    signal IMdata_i, DMdataIN_i, DMdataOUT_i: std_logic_vector(Nbit-1 downto 0);
    signal controlWordOut_s: std_logic_vector(controlNbit-1 downto 0);
    signal IMaddress_i, DMaddress_i: std_logic_vector(addressNbit-1 downto 0);
    signal decode_cwd_i : STD_LOGIC_VECTOR(CW_SIZE-1 DOWNTO 0);
    signal execute_cwd_i :  STD_LOGIC_VECTOR (CW_SIZE-1-5 DOWNTO 0);
    signal memory_cwd_i :  STD_LOGIC_VECTOR (CW_SIZE-1-17 DOWNTO 0);
    signal wb_cwd_i :  STD_LOGIC_VECTOR (CW_SIZE-1-20 DOWNTO 0);
    signal IR_ID_s, IR_EX_s, IR_MEM_s, IR_WB_s: std_logic_vector(Nbit-1 downto 0);
    signal hzd_sig_ctrl_s, hzd_sig_raw_s, hzd_sig_jmp_s: std_logic ;

    
    constant ADDI1BITWISE: std_logic_vector(Nbit-1 downto 0) := "00000100000000010000000000000001" ; -- label: addi r1, r0, 1                      assumed starting memAddress: 0000 0000
    constant ADDI2BITWISE: std_logic_vector(Nbit-1 downto 0) := "00000100000000100000000000000010" ; --        addi r2, r0, 2                      memAddress:                  0000 0004
    constant SUBI1BITWISE: std_logic_vector(Nbit-1 downto 0) := "00001100000000110000000000000000" ; --        subi r3, r0, 0                      memAddress:                  0000 0008
    constant ORI1BITWISE: std_logic_vector(Nbit-1 downto 0) :=  "00010100000001000000000000000010" ;  --       ori  r4, r0, 2                      memAddress:                  0000 000C
    constant ADD1BITWISE: std_logic_vector(Nbit-1 downto 0) :=  "00000000001000100010100000000000" ;  --       add  r5, r1, r2                     memAddress:                  0000 0010
    --constant BEQZ1BITWISE: std_logic_vector(Nbit-1 downto 0) := "00101000010000001111111111101000" ; --        beqz r2, label ; nn dovrebbe saltare                             0000 0014
    --constant BNEZ1BITWISE: std_logic_vector(Nbit-1 downto 0) := "00101100010000001111111111100100" ; --        bnez r2, label ; dovrebbe saltare                                0000 0018
    constant JALBITWISE:   std_logic_vector(Nbit-1 downto 0) := "10000111111111111111111111101000";  --         jal label                   memAddress: 0000 0014
    constant STWBITWISE: std_logic_vector(Nbit-1 downto 0) :=   "00110100010000010000000000010101" ; --        stw 21(r2), r1;
    constant LDWBITWISE: std_logic_vector(Nbit-1 downto 0) :=   "00110000001010010000000000010110" ; --         ldw r9, 22(r1) ;

begin

        -- instance of DP
       DP: BasicDP
	   generic map (NbitMem => Nbit, controlNbit => controlNbit, addressNbit => addressNbit)
       port map (
                clk => Clock,
                rst => Reset,
                fromHU => fromHU_i,
                enable => enable_i,
                IMdata => IMdata_i, --is input data from the IRAM
                controlWord => controlWordOut_s,
                DMdataIN => DMdataIN_i,
                IMaddress => IMaddress_i,
                DMaddress => DMaddress_i,
                DMdataOUT => DMdataOUT_i
               );

        CUwithHU: CU_dlx
        generic map( 41, 11, 6, 25)
        port map (
            clk => Clock,
            reset => Reset,
            IR_in => Imdata_i,
            hzd_sig_jmp => hzd_sig_jmp_s,
            hzd_sig_ctrl => hzd_sig_ctrl_s,
            hzd_sig_raw => hzd_sig_raw_s,
            decode_cwd => decode_cwd_i,
            execute_cwd => execute_cwd_i,
            memory_cwd => memory_cwd_i,
            wb_cwd => wb_cwd_i,
            IR_ID => IR_ID_s,
            IR_EX => IR_EX_s,
            IR_MEM => IR_MEM_s,
            IR_WB => IR_WB_s 
        );

        --CU: CUbasic
        --generic map( 41, 11, 6, 25)
        --port map (
        --    clk => Clock,
        --    reset => Reset,
        --    IR_in => Imdata_i,
        --    decode_cwd => decode_cwd_i,
        --    execute_cwd => execute_cwd_i,
        --    memory_cwd => memory_cwd_i,
        --    wb_cwd => wb_cwd_i,
        --    controlWordOut => controlWordOut_s
        --);

        Imem: IRAM
        generic map (32, 32)
        port map (
            clk => Clock,
            rst => reset,
            I_ADDR => IMaddress_i,
            I_DATA => IMdata_i,
            ready => readyIRAM_i
        );

        Dmem: DRAM
        generic map(32, 32)
        port map (
            clk => Clock,
            rst => reset,
            EN => controlWordOut_s(controlNbit-19),
            RW => controlWordOut_s(controlNbit-18), --corresponds to RW control bit from control word
            ADDR => DMaddress_i,
            DATA_IN => DMdataOUT_i, --the data going as input to the DMEM is the data going as OUTPUT from dp
            DATA_OUT => DMdataIN_i, --the data going output from DMEM is INPUT to the DP
            ready => readyDRAM_i
        );

        Clock <= not Clock after 1 ns;
	    Reset <= '1', '0' after 2.5 ns;
        enable_i <= '1' after 1.5 ns;

        controlWordOut_s <= decode_cwd_i(25-1 downto 20) & execute_cwd_i(19 downto 8) & memory_cwd_i(7 downto 5) & wb_cwd_i(4 downto 0) ;

        DPSampleSignals: process

        --IM memory address is expressed on 32 bits
        --

        --Simple Program with no stalls--

        --           
        --  addi r1, r0, 1                     corrisponding Imem address x"00000000"   
        --  addi r2, r0, 2                     corrisponding Imem address x"00000004"
        --  subi r3, r0, 1                     corrisponding Imem address x"00000008"
        --  ori  r4, r0, 2                     corrisponding Imem address x"0000000C"
        --  add  r5, r1, r2                    corrisponding Imem address x"00000010"

        begin

        wait for 1 ns;  

        --IM
        wait for 2 ns;
        --in this instant, fetch of first instr

        --IMdata_i <= ADDI1BITWISE; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)

        --ControlWord_i <= (others => '0');
        

        wait for 2 ns;
	    --IMdata_i <= ADDI2BITWISE; -- instruction bits corresponding to -addi r2, r0, 2- 	       
        

        --ControlWord_i <= CWIdBitsADDI & "000000000000" & "000" & "00000" ;

        wait for 2 ns;

        --IMdata_i <= SUBI1BITWISE; -- instruction bits corresponding to -subi r3, r0, 1- (opcode assumed for subi is 00011)

        --ControlWord_i <= CWIDbitsADDI & CWExBitsADDI & "000" & "00000"  ;


        wait for 2 ns;
	    --IMdata_i <= ORI1BITWISE; -- instruction bits corresponding to -ori r4, r0, 2- 	

        --controlword_i <= CWIdbitsSUBI & CWexbitsADDI & CWMemBitsADDI & "00000" ;

        wait for 2 ns;
	
        --IMdata_i <= ADD1BITWISE; --instruction bits corresponding to 5th instruction: -add r5, r1, r2-  (opcode assumed for the add Rtype is 000000 and related FUNC is 00000000000 )

        --controlword_i <= CWIdBitsORI & CWExBitsSUBI & CWMemBitsADDI & CWWBBitsADDI;

        wait for 2 ns;

        --IMdata_i <= BEQZ1BITWISE;
       -- IMdata_i <=  JALBITWISE; --fetching of the JAL instr

        --controlWord_i <= CWIdBitsADD & CWExBitsORI & CWMemBitsSUBI & CWWBBitsADDI ;
		
        wait for 2 ns; 

        --controlWord_i <= JAL_DECODE & CWExBitsADD & CWMemBitsORI & CWWBBitsSUBI ;

        wait for 2 ns;

        --controlWord_i <= "00000" & JAL_EXECUTE & CWMemBitsADD & CWWBBitsORI ;

        wait for 2 ns;

        --controlword_i <= "00000" & "000000000000" & JAL_MEMORY & CWWbbitsAdd ;

        wait for 2 ns;

        --IMdata_i <= ADDI1BITWISE; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)

        --controlwordOut_s <= CWIdBitsADDI & "000000000000" & "000" & JAL_WB ;

        wait for 2 ns;
        
        --IMdata_i <= ADDI1BITWISE; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)


        wait for 2 ns;

        --IMdata_i <= ADDI2BITWISE; 


        wait for 2 ns;

        wait for 2 ns;

        wait for 2 ns;
        wait;

        end process;

end TESTPROVA;