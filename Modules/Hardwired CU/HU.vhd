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
        IR_ID: IN std_logic_vector(Nbit-1 downto 0);
        --PC_SEL: OUT std_logic;        -- selection signal for value of PC 
        -- input diretto dal datapath per dire se branch presa o no;
        hzd_sig_ctrl : OUT STD_LOGIC;
        hzd_sig_raw : OUT STD_LOGIC;
        --hzd_sig_raw_2clk : OUT STD_LOGIC -- hazard signals
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
        if(rising_edge(clk)) then
            --hzd_sig_raw <= '0';
            -- R_TYPE
            if(IR_ID(Nbit-1) = '0') then                    
                -- if IR_ID (Rs) = IR_EX (Rd)  -> hazard
                if((IR_ID(Nbit-7 downto Nbit-11) = IR_EX(Nbit-17 downto 21)) or (IR_ID(Nbit-12 downto Nbit-16) = IR_EX(Nbit-17 downto 21)) ) then 
                    hzd_sig_raw <= '1';
                -- if IR_ID(Rs) = IR_MEM (Rd) -> hazard
                else if((IR_ID(Nbit-7 downto Nbit-11) = IR_MEM(Nbit-17 downto 21)) or (IR_ID(Nbit-12 downto Nbit-16) = IR_MEM(Nbit-17 downto 21)) ) then 
                    hzd_sig_raw <= '1';
                else                                    -- normal execution can proceed                  
                    hzd_sig_raw <= '0';                      
                end if;
            end if;
        end if;
    end process;
    


end architecture beh;
