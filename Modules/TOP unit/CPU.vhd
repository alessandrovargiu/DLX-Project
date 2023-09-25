LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;

ENTITY CPU IS
    PORT (              
        clk : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
        reset : IN STD_LOGIC; -- Reset Signal: Asyncronous Active Low (Negative)
        Instr_in : IN std_logic_vector (Nbit-1 downto 0);
    );
END ENTITY CPU;

ARCHITECTURE behavioral OF CPU IS

component CU_dlx is
        GENERIC (
            MICROCODE_MEM_SIZE : INTEGER := 41; -- Microcode Memory Size
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
end component;

component HU is
    PORT (              
        clk : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
        rst : IN STD_LOGIC; -- Reset Signal: Asyncronous Active Low (Negative)
        cwd : IN STD_LOGIC_VECTOR(25-1 DOWNTO 0); -- datapath signals
        IR_ID: IN std_logic_vector(Nbit-1 downto 0);
        IR_EX: IN std_logic_vector(Nbit-1 downto 0);
        IR_MEM: IN std_logic_vector(Nbit-1 downto 0);
        IR_WB: IN std_logic_vector(Nbit-1 downto 0);
        branchStatus: IN std_logic;
        PC_SEL: OUT std_logic;        -- selection signal for value of PC
        hzd_sig_jmp : out std_logic;        
        hzd_sig_ctrl : OUT STD_LOGIC;
        hzd_sig_raw : OUT STD_LOGIC
    );
END component;

component BasicDp is
    Generic( NbitMem: integer;
             controlNbit: integer;
             addressNbit: integer );
    port(   Clk:        in std_logic;
            rst:        in std_logic;
            
            fromHU:      in std_logic;
            enable:      in std_logic;
            IMdata:      in std_logic_vector(NbitMem-1 downto 0);  --is the instruction entering the dp and is input to the IR pipeline register in IF/ID bank
            controlWord: in std_logic_vector(controlNbit-1 downto 0);
            DMdataIn:    in std_logic_vector(NbitMem-1 downto 0);

            IMAddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMdataOut:   out std_logic_vector(NbitMem -1 downto 0)
            
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
        RW: in std_logic;                             -- 1 - read, 0 - write
        ADDR: in std_logic_vector(W-1 downto 0);          
        DATA_IN: in std_logic_vector(N-1 downto 0);
        DATA_OUT: out std_logic_vector(N-1 downto 0);
        ready : out std_logic                         -- active high
    );
end component;

component IRAM is 
    generic (
        N: integer := 32;-- constants here
        M: integer := 32
    );
    port(
        clk: in std_logic;
        rst: in std_logic;                            -- active low
        I_ADDR : in std_logic_vector(N-1 downto 0);     -- dimensions to be specified     
        I_DATA : out std_logic_vector(M-1 downto 0);
        ready : out std_logic                         -- active high
    );
end component;
 
signal decode_cwd_s : STD_LOGIC_VECTOR(CW_SIZE-1 DOWNTO 0);
signal execute_cwd_s :STD_LOGIC_VECTOR (CW_SIZE-1-5 DOWNTO 0);
signal memory_cwd_s : STD_LOGIC_VECTOR (CW_SIZE-1-17 DOWNTO 0);
signal wb_cwd_s :     STD_LOGIC_VECTOR (CW_SIZE-1-20 DOWNTO 0);
signal IR_ID_s:  std_logic_vector(Nbit-1 downto 0);
signal IR_EX_s:  std_logic_vector(Nbit-1 downto 0);
signal IR_MEM_s:  std_logic_vector(Nbit-1 downto 0);
signal IR_WB_s:  std_logic_vector(Nbit-1 downto 0);
signal hzd_sig_jmp_s: std_logic;
signal hzd_sig_ctrl_s: std_logic;
signal hzd_sig_raw_s:  std_logic;
signal cwd_s :  STD_LOGIC_VECTOR(25-1 DOWNTO 0);
signal branchStatus_s : std_logic;
signal PC_SEL_s:  std_logic;
signal RW_s:  std_logic;                             -- 1 - read, 0 - write
signal DramADDR_s:  std_logic_vector(W-1 downto 0);          
signal DramDATA_IN_s:  std_logic_vector(N-1 downto 0);
signal DramDATA_OUT_s:  std_logic_vector(N-1 downto 0);
signal readyDram_s :  std_logic;
signal readyIram_s :  std_logic;
signal IramADDR_s :   std_logic_vector(N-1 downto 0);
signal IramDATA_s :   std_logic_vector(M-1 downto 0);
signal enable_s:  std_logic; 




begin

    CU : CU_dlx
    generic map()
    port map(clk,reset,Inst_in,hzd_sig_jmp_s,hzd_sig_ctrl_s,hzd_sig_raw_s,decode_cwd_s,execute_cwd_s,memory_cwd_s,wb_cwd_s,IR_ID_s,IR_EX_s,IR_MEM_s,IR_WB_s);

    HU : HU
    generic map()
    port map(clk,reset,cwd_s,IR_ID_s,IR_EX_s,IR_MEM_s,IR_WB_s,branchstatus_s,PC_SEL_s,hzd_sig_jmp_s,hzd_sig_ctrl_s,hzd_sig_raw_s);

    DRAM : DRAM
    generic map()
    port map(clk,reset,rw_s,Dramaddr_s,Dramdata_in_s,Dramdata_out_s,readyDram_s);

    IRAM : IRAM
    generic map()
    port map(clk,reset,IramADDR_s,IramDATA_s,readyIram_s);

    DP: BasicDP
    generic map()
    port map (
                clk => Clock,
                rst => Reset,
                fromHU => PC_SEL_s,
                enable => enable_s,
                IMdata => Iramdata_s, --is input data from the IRAM
                controlWord => decode_cwd_s,
                DMdataIN => Dramdata_out_s,
                IMaddress => IramADDR_s,
                DMaddress => Dramaddr_s,
                DMdataOUT => Dramdata_in_s
               );

            
end architecture;












