LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;

ENTITY HU IS
    PORT (              
        clk : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
        rst : IN STD_LOGIC; -- Reset Signal: Asyncronous Active Low (Negative)
        cwd : IN STD_LOGIC_VECTOR(25-1 DOWNTO 0); -- datapath signals
        IR_ID: in std_logic_vector(Nbit-1 downto 0);
        --IR_EX: in std_logic_vector(Nbit-1 downto 0);
        hzd_sig_ctrl : OUT STD_LOGIC;
        hzd_sig_raw : OUT STD_LOGIC -- hazard signals
    );
END ENTITY HU;

ARCHITECTURE beh OF HU IS
    --flush_j,flush_b: std_logic;
    signal IR_ID_s,IR_EX, IR_MEM, IR_WB: std_logic_vector(Nbit-1 downto 0);   

BEGIN
    -- instruction pipeline
    IR_ID_s<=IR_ID;
    pipe: process (clk)
    begin
        if(rising_edge(clk)) then
            IR_EX <= IR_ID_s;
            IR_MEM <= IR_EX;
            IR_WB <= IR_MEM;
        end if;
    end process;

    Ctrl : PROCESS (cwd)
        begin
             hzd_sig_ctrl <= '0';
            IF (cwd = JMP_CWD) THEN
                hzd_sig_ctrl <= '1';
            END IF;
            IF (cwd = JAL_CWD) THEN
                hzd_sig_ctrl <= '1';
            END IF;
           -- IF (cwd = BEQZ_CWD) THEN
               -- IF () THEN --- if il segnale che esce dall output allora è preso o no il branch
                --hzd_sig_ctrl <= '1';
            --END IF;
        --END IF;
        --IF (cwd = BNEZ_CWD) THEN
            --IF () THEN --- if il segnale che esce dall output allora è preso o no il branch
            --    hzd_sig_ctrl <= '1';
            --END IF;
        --END IF;
    END PROCESS;

    ------------------- RAW hazard detection ------------------
    -- hazard check done on ID stage 
    -- possibility of forwarding implementation in the future
    -- IR opcode MSB is 1 for JUMPS, 0 for all other instructions which are subject to RAW hazards

    RAW: process (clk)
    begin
        hzd_sig_raw <= '0';
        if(rising_edge(clk)) then
            if(IR_ID(Nbit-1) = '0' AND IR_EX(Nbit-1 downto Nbit-6) = ITYPE_LDW) then
                if(IR_ID(Nbit-7 downto Nbit-12) = IR_EX(Nbit-7 downto Nbit-12)) then -- RS1 data dependency
                    hzd_sig_raw <= '1';
                end if;
            end if;
        
            if(IR_ID(Nbit-1 downto Nbit-6) = RTYPE OR IR_ID(Nbit-1 downto Nbit-6) = ITYPE_BEQZ OR IR_ID(Nbit-1 downto Nbit-6) = ITYPE_BNEZ) then
                if(IR_ID(Nbit-13 downto Nbit-18) = IR_EX(Nbit-13 downto Nbit-18)) then -- RS2 data dependency
                    hzd_sig_raw <= '1';
                end if;
            end if;
        end if;
    end process;
    


end architecture beh;
