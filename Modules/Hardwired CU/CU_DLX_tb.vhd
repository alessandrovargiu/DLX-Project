LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;

entity tb is
end tb;


architecture test of tb is

    component CU_dlx is
        GENERIC (
            MICROCODE_MEM_SIZE : INTEGER := 41; -- Microcode Memory Size
            FUNC_SIZE : INTEGER := 11; -- Func Field Size for R-Type Ops
            OP_CODE_SIZE : INTEGER := 6; -- Op Code Size
            CW_SIZE : INTEGER := 25 -- output signals of CU
            --ALU_SIZE : Integer := 2    --2 bits for 4 operations 0 1 2 3
        );
        port (
            clk: in std_logic;
            reset: in std_logic;
            --stall: in std_logic;
            --jump: in std_logic;
            IR_in: in std_logic_vector(Nbit-1 downto 0);
            IR_ID: OUT std_logic_vector(Nbit-1 downto 0);
            IR_EX: OUT std_logic_vector(Nbit-1 downto 0);
            IR_MEM: OUT std_logic_vector(Nbit-1 downto 0);
            IR_WB: OUT std_logic_vector(Nbit-1 downto 0);
            hzd_sig_jmp: in std_logic;
            hzd_sig_ctrl: in std_logic;
            hzd_sig_raw: in std_logic;
            --PC_SEL: OUT std_logic;
            decode_cwd: out std_logic_vector(CW_SIZE-1 downto 0);
            execute_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-5 DOWNTO 0);
            memory_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-17 DOWNTO 0);
            wb_cwd : OUT STD_LOGIC_VECTOR (CW_SIZE-1-20 DOWNTO 0)
        );
    end component CU_dlx;

    component HU is
        PORT (              
            clk : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
            rst : IN STD_LOGIC; -- Reset Signal: Asyncronous Active Low (Negative)
            cwd : IN STD_LOGIC_VECTOR(25-1 DOWNTO 0); -- datapath signals
            IR_ID: in std_logic_vector(Nbit-1 downto 0);
            IR_EX: IN std_logic_vector(Nbit-1 downto 0);
            IR_MEM: IN std_logic_vector(Nbit-1 downto 0);
            IR_WB: IN std_logic_vector(Nbit-1 downto 0);
            branchStatus: IN std_logic;
            PC_SEL: OUT std_logic;        -- selection signal for value of PC 
            hzd_sig_jmp: OUT std_logic;
            hzd_sig_ctrl : OUT STD_LOGIC; -- hazard signals
            hzd_sig_raw : OUT STD_LOGIC
    );
    end component HU;

    signal clk_s, reset_s, hzd_sig_ctrl_s, hzd_sig_raw_s, hzd_sig_jmp_s, branchStatus_s: std_logic;
    signal IR_in_s: std_logic_vector(Nbit-1 downto 0);
    signal PC_SEL_s: std_logic;
    signal decode_cwd_s: std_logic_vector(24 downto 0);
    signal execute_cwd_s : STD_LOGIC_VECTOR (19 DOWNTO 0);
    signal memory_cwd_s : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal wb_cwd_s : STD_LOGIC_VECTOR (4 DOWNTO 0);
    signal cwd_s: std_logic_vector(25-1 downto 0);
    signal IR_ID_s: std_logic_vector(Nbit-1 downto 0);
    signal IR_EX_s: std_logic_vector(Nbit-1 downto 0);
    signal IR_MEM_s: std_logic_vector(Nbit-1 downto 0);
    signal IR_WB_s: std_logic_vector(Nbit-1 downto 0);

    
begin

    cwd_s <= decode_cwd_s(24 downto 0); --& execute_cwd_s (19 downto 10) & memory_cwd_s(9 downto 5) & wb_cwd_s;

    ClkProcess: PROCESS
    BEGIN
       Clk_s <= '0';
       WAIT FOR 0.5 ns;
       Clk_s <= '1'; 
       WAIT FOR 0.5 ns;
    END PROCESS;

    UUT: CU_dlx
    generic map(41, 11, 6, 25)
    port map(
        clk => clk_s,
        reset => reset_s,
        hzd_sig_raw => hzd_sig_raw_s,
        hzd_sig_ctrl => hzd_sig_ctrl_s,
        hzd_sig_jmp => hzd_sig_jmp_s,
        --PC_SEL => PC_SEL_s,
        IR_in => IR_in_s,
        IR_ID => IR_ID_s,
        IR_EX => IR_EX_s,
        IR_MEM => IR_MEM_s,
        IR_WB => IR_WB_s,
        decode_cwd => decode_cwd_s,
        execute_cwd => execute_cwd_s,
        memory_cwd => memory_cwd_s,
        wb_cwd => wb_cwd_s
    );

    UUT2: HU
    port map(
        clk_s, 
        reset_s,
        cwd_s,
        IR_ID_s,
        IR_EX_s,
        IR_MEM_s,
        IR_WB_s,
        branchStatus_s,
        PC_SEL_s,
        hzd_sig_jmp_s, 
        hzd_sig_ctrl_s,
        hzd_sig_raw_s);


    test: process
    begin

        -- LD R1, #imm
        -- SUB R17, R1, R16
        -- ADD R18, R3, R4
        -- ADD R19, R4, R4
        -- SUB R17, R1, r16
        reset_s <= '1';
        wait for 1 ns;
        reset_s <= '0';
        wait for 1 ns;
        --IR_in_s <= "001100" & "00001" & "00010" & "0101010101010101";
        --wait for 1 ns;
        --IR_in_s <= "000000" & "00001" & "01000" & "01001" & "00000000001";
        --wait for 1 ns;
        --IR_in_s <= "000000" & "00011" & "00100" & "01010" & "00000000000";
        --wait for 1 ns;
        --IR_in_s <= "000000" & "00100" & "00100" & "01011" & "00000000000";
        --wait for 1 ns;
        --IR_in_s <= "000000" & "00001" & "01000" & "01001" & "00000000001";
        
        -- ADD R3, R1, R2
        --IR_in_s <= "000000" & "00001" & "00010" & "00011" & "00000000000";
        --wait for 1 ns;
        -- ADD R4, R3, R1
        --IR_in_s <= "000000" & "00011" & "00001" & "00100" & "00000000000";
        --wait for 1 ns;
        -- JUMP R10
        --IR_in_s <= "100000" & "00000000000000000000000010";
        --wait for 1 ns;
        -- AND R5, R1, R2
        --IR_in_s <= "000000" & "00001" & "00010" & "00101" & "00000000010";
        
        -- cannot inject instructions right after jump because we have to simulate
        -- PC reg being stalled as well -> after 10 ns we check if RAW hazards are
        -- detected correctly

        -- STUFF TO REMEMBER: 
        --    this CU takes IR_in as input, which means that when we inject NOP in decode stage
        --    IR_in stays with the same instruction that has caused the stall (since PC is stopped),
        --    causing pipeline to feed old instruction instead of NOPs and so hzd signal stays high.
        --    this has to change (maybe we inject NOPs in IR_in_s and feed that to the decode instead of
        --    putting IR_in directly)
        --
        --ADD R4, R0, R1
        IR_in_s <= "000000" & "00000" & "00001" & "00100" & "00000000000";
        wait for 1 ns;
        --BEQZ R4, label                   -> RAW hazard with ADD above
        IR_in_s <= "001010" & "00100" & "00000"  & "0101010101010101";
        wait for 1 ns;
        -- NOP
        --IR_in_s <= "000010" & "00000" & "00000" & "0000000000000000";
        --wait for 10 ns;
        --SUB R6, R1, R2
        IR_in_s <= "000000" & "00001" & "00010" & "00110" & "00000000001";
        wait for 1 ns;
        --ADD R7, R1, R2
        IR_in_s <= "000000" & "00001" & "00010" & "00111" & "00000000000";
        wait for 1 ns;
        -- SUB R8, R6, R2           -> RAW HAZARD
        IR_in_s <= "000000" & "00110" & "00010" & "01001" & "00000000001";
        wait for 1 ns;
        --ADD R9, R1, R2
        IR_in_s <= "000000" & "00001" & "00010" & "01001" & "00000000000";
        wait for 1 ns;

        --questa prova sotto , non si alza pc sel
        --ADD R5, R0, R1
        --IR_in_s <= "000000" & "00000" & "00001" & "00101" & "00000000000";
        --wait for 1 ns;
        --BEQZ R4, label              -->     ctrl_hazd
        --IR_in_s <= "001010" & "00100" & "00000"  & "0101010101010101";
        --wait for 1.5 ns;
        --branchstatus_s <= '1';
        --wait for 1 ns;
        --branchstatus_s <= '0';
        --wait 1 ns;

        
        -- prova per jump 
        -- ADD R3, R1, R2
        --IR_in_s <= "000000" & "00001" & "00010" & "00011" & "00000000000";
       -- wait for 1 ns;
        -- JUMP R10
        --IR_in_s <= "100000" & "00000000000000000000000010";
        --wait for 1 ns;
        --ADD R5, R0, R1
        --IR_in_s <= "000000" & "00000" & "00001" & "00101" & "00000000000";
        --wait for 1 ns;


        
    wait;
    end process;


end architecture test;









