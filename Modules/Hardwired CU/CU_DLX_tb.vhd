LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE work.INSTR_CODES.ALL;

entity tb is
end tb;


architecture test of tb is

    component CU_dlx is
        GENERIC (
            MICROCODE_MEM_SIZE : INTEGER := 41; -- Microcode Memory Size
            FUNC_SIZE : INTEGER := 11; -- Func Field Size for R-Type Ops
            OP_CODE_SIZE : INTEGER := 6; -- Op Code Size
            CW_SIZE : INTEGER := 25; -- output signals of CU
            --ALU_SIZE : Integer := 2    --2 bits for 4 operations 0 1 2 3
        );
        port (
            clk: in std_logic;
            reset: in std_logic;
            stall: in std_logic;
            jump: in std_logic;
            IR_in: in std_logic_vector(Nbit-1 downto 0);
            decode_cwd: out std_logic_vector(CW_SIZE-1 downto 0);
            execute_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1 DOWNTO 0);
            memory_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1 DOWNTO 0);
            wb_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1 DOWNTO 0);
        );
    end CU_dlx;

    component HU is
        PORT (              
            clk : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
            rst : IN STD_LOGIC; -- Reset Signal: Asyncronous Active Low (Negative)
            cwd : IN STD_LOGIC_VECTOR(25 DOWNTO 0); -- datapath signals
            IR_ID: in std_logic_vector(Nbit-1 downto 0);
            hzd_sig : OUT STD_LOGIC -- hazard signals
    );
    end HU;

    signal clk_s, reset_s, hzd_sig_s: std_logic;
    signal IR_in_s: std_logic_vector(Nbit-1 downto 0);
    signal cwd_s: std_logic_vector(25 downto 0);
    signal decode_cwd_s: std_logic_vector(4 downto 0);
    signal execute_cwd_s : STD_LOGIC_VECTOR (9 DOWNTO 0);
    signal memory_cwd_s : STD_LOGIC_VECTOR (4 DOWNTO 0);
    signal wb_cwd_s : STD_LOGIC_VECTOR (4 DOWNTO 0);
    
    
    
begin

    UUT: CU_dlx
    generic map(MICROCODE_MEM_SIZE, FUNC_SIZE, OP_CODE_SIZE, CW_SIZE)
    port map(
        clk => clk_s,
        reset => reset_s,
        stall => '0',
        jump => '0',
        IR_in => IR_in_s,
        decode_cwd => decode_cwd_s,
        execute_cwd => execute_cwd_s,
        memory_cwd => memory_cwd_s,
        wb_cwd_s => wb_cwd_s
    );

    UUT2: HU
    port map(
        clk_s, 
        reset_s, 
        decode_cwd_s & execute_cwd_s & memory_cwd_s & wb_cwd_s, 
        IR_in_s, 
        hzd_sig_s);

    clock: process
    begin
        clk_s <= not(clk_s) after 0.5 ns;
    end process;

    test: process
    begin
        reset_s <= '0';
        -- 1st instr. -> LD R1, #imm
        IR_in_s <= "001100" & "00001" & "00010" & "0101010101010101";
        wait for 0.5ns;
        -- 2nd instr. -> SUB R17, R1, R16  -> RAW hazard
        IR_in_s <= "000000" & "00001" & "01000" & "01001" & "00000000001";
    wait;
    end process;


end architecture test;









