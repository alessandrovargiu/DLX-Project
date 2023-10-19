LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;

ENTITY CPU IS
    PORT (              
        CLK : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
        reset : IN STD_LOGIC; -- Reset Signal: Asyncronous Active Low (Negative)
        enable: in std_logic;
		IramDATA: in std_logic_vector(31 downto 0);
		IramADDR: out std_logic_vector (31 downto 0);
		DramDATA_OUT: out std_Logic_vector (31 downto 0);
		DramADDR: out std_logic_vector (31 downto 0);
		DramDATA_IN: in std_logic_vector (31 downto 0);
		cw_mem_bits: out std_logic_vector (1 downto 0)
		
        --Instr_in : IN std_logic_vector (Nbit-1 downto 0)
    );
END ENTITY CPU;

ARCHITECTURE DLX_arch OF CPU IS

component CU_dlx is
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
    --Generic( NbitMem: integer;
         --    controlNbit: integer;
           --  addressNbit: integer );
    port(   Clk:        in std_logic;
            rst:        in std_logic;
            
            fromHU:      in std_logic;
            hzd_sig_jmp: in std_logic;
            enable:      in std_logic;
            IMdata:      in std_logic_vector(NbitMem-1 downto 0);  --is the instruction entering the dp and is input to the IR pipeline register in IF/ID bank
            controlWord: in std_logic_vector(controlNbit-1 downto 0);
            DMdataIn:    in std_logic_vector(NbitMem-1 downto 0);

            IMAddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMdataOut:   out std_logic_vector(NbitMem -1 downto 0);
            B_status: out std_logic;
            IR0_out:  out std_logic_vector(Nbit-1 downto 0);
            IROutID:  out std_logic_vector(Nbit-1 downto 0)
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
signal IramADDR_s :   std_logic_vector(N-1 downto 0);
signal IramDATA_s :   std_logic_vector(M-1 downto 0);
signal controlWord_s: std_logic_vector(CW_SIZE-1 downto 0);
signal IR0_out_s: std_logic_vector(Nbit-1 downto 0);
 

begin

    CU : CU_dlx
    
    port map(clk => clk,
            reset => reset,
            IR_in => IR0_out_s,
            hzd_sig_jmp => hzd_sig_jmp_s,
            hzd_sig_ctrl => hzd_sig_ctrl_s,
            hzd_sig_raw => hzd_sig_raw_s,
            decode_cwd => decode_cwd_s,
            execute_cwd => execute_cwd_s,
            memory_cwd => memory_cwd_s,
            wb_cwd => wb_cwd_s,
            IR_ID => IR_ID_s,
            IR_EX => IR_EX_s,
            IR_MEM => IR_MEM_s,
            IR_WB => IR_WB_s
        );  

    HU1 : HU
    port map(clk,
            reset,
            cwd_s,
            IR_ID_s,
            IR_EX_s,
            IR_MEM_s,
            IR_WB_s,
            branchstatus_s,
            PC_SEL_s,
            hzd_sig_jmp_s,
            hzd_sig_ctrl_s,
            hzd_sig_raw_s
        );

    DP: BasicDP 
    port map (
                clk => clk,
                rst => Reset,
                fromHU => PC_SEL_s,
                hzd_sig_jmp => hzd_sig_jmp_s,
                enable => enable,
                IMdata => Iramdata, --is input data from the IRAM
                controlWord => controlWord_s,
                DMdataIN => Dramdata_in,
                IMaddress => IramADDR_s,
                DMaddress => Dramaddr_s,
                DMdataOUT => Dramdata_out_s,
                B_status => branchstatus_s,
                IROutID => open,
                IR0_out => IR0_out_s
               );

    IramADDR <= IramADDR_s;
    DramADDR <= DramADDR_s;
    DramDATA_OUT <= DramDATA_out_s;
    controlWord_s <= decode_cwd_s(24 downto 20) & execute_cwd_s(19 downto 8) & memory_cwd_s(7 downto 5) & wb_cwd_s(4 downto 0);
    cw_mem_bits <= controlword_s(controlnbit-18) & controlword_s(controlnbit-19);        

end architecture;

configuration CFG_CPU of CPU is
    for DLX_arch 
    end for;
end configuration;










