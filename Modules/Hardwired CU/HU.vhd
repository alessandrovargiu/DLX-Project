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
        IR_EX: IN std_logic_vector(Nbit-1 downto 0);
        IR_MEM: IN std_logic_vector(Nbit-1 downto 0);
        IR_WB: IN std_logic_vector(Nbit-1 downto 0);
        branchStatus: IN std_logic;
        PC_SEL: OUT std_logic;        -- selection signal for value of PC
        hzd_sig_jmp : out std_logic;        
        hzd_sig_ctrl : OUT STD_LOGIC;
        hzd_sig_raw : OUT STD_LOGIC
        --hzd_sig_raw_2clk : OUT STD_LOGIC -- hazard signals
    );
END ENTITY HU;

ARCHITECTURE beh OF HU IS
    --flush_j,flush_b: std_logic;
    signal ID_Rs1, ID_Rs2, ID_Rd: std_logic_vector(4 downto 0);
    signal EX_Rd: std_logic_vector(4 downto 0);
    signal MEM_Rd: std_logic_vector(4 downto 0);
    signal WB_Rd: std_logic_vector(4 downto 0);
BEGIN

    fetch: process(IR_ID)
    begin
        if(IR_ID(Nbit-1 downto Nbit-6) = RTYPE) then
            ID_Rs1 <= IR_ID(Nbit-7 downto Nbit-11);
            ID_Rs2 <= IR_ID(Nbit-12 downto Nbit-16);
            ID_Rd <= IR_ID(Nbit-17 downto Nbit-21);
        elsif(IR_ID(Nbit-1 downto Nbit-6) = ITYPE_BEQZ OR IR_ID(Nbit-1 downto Nbit-6) = ITYPE_BNEZ) then
            ID_Rs1 <= IR_ID(Nbit-7 downto Nbit-11);
            ID_Rd <= "00000";
        elsif(IR_ID(Nbit-1 downto Nbit-6) /= "000000") then
            ID_Rs1 <= IR_ID(Nbit-7 downto Nbit-11);
            ID_Rd <= IR_ID(Nbit-12 downto Nbit-16);
        end if;
    end process;

    pipe: process(clk)
    begin
        if(rst = '0' AND rising_edge(clk)) then
            EX_Rd <= "00000";
            MEM_Rd <= "00000";
            WB_Rd <= "00000";
            if(IR_EX(Nbit-1 downto Nbit-6) /= NOP) then
                EX_Rd <= ID_Rd;
            end if;
            --if(IR_MEM(Nbit-1 downto Nbit-6) /= NOP) then
                MEM_Rd <= EX_Rd;
            --end if;
           -- if(IR_WB(Nbit-1 downto Nbit-6) /= NOP) then
                WB_Rd <= MEM_Rd;
           -- end if; 
        end if;
    end process;
    
    ------------------- RAW hazard detection ------------------
    -- hazard check done on ID stage 
    -- possibility of forwarding implementation in the future
    -- IR opcode MSB is 1 for JUMPS, 0 for all other instructions which are subject to RAW hazards

    RAW: process (clk)
    begin
        if(rst = '0' AND falling_edge(clk)) then
            -- COND BRANCH TAKEN hazard
            if(branchStatus = '1') then
                hzd_sig_ctrl <= '1';
                PC_SEL <= '1';
            else
                hzd_sig_ctrl <= '0';
                PC_SEL <= '0';
            end if;

            if(((IR_ID(Nbit-1 downto Nbit-6) /= "000010") AND IR_EX(Nbit-1 downto Nbit-6) /= "000010") OR ((IR_ID(Nbit-1 downto Nbit-6) /= "000010") AND IR_MEM(Nbit-1 downto Nbit-6) /= "000010") OR ((IR_ID(Nbit-1 downto Nbit-6) /= "000010") AND IR_WB(Nbit-1 downto Nbit-6) /= "000010")) then
                if (IR_ID(Nbit-1 downto Nbit-6) = JTYPE_JMP or IR_EX(Nbit-1 downto Nbit-6) = JTYPE_JMP or IR_MEM(Nbit-1 downto Nbit-6) = JTYPE_JMP) THEN
                    hzd_sig_jmp <= '1';
                    PC_SEL <= '1';
                elsif (IR_ID(Nbit-1 downto Nbit-6) = JTYPE_JAL or IR_EX(Nbit-1 downto Nbit-6) = JTYPE_JAL or IR_MEM(Nbit-1 downto Nbit-6) = JTYPE_JAL) THEN
                    hzd_sig_jmp <= '1';
                    PC_SEL <= '1';
                else
                    hzd_sig_jmp <= '0';
                    PC_SEL <= '0'; 
                    if((ID_Rs1 = EX_Rd OR ID_Rs2 = EX_Rd) AND EX_Rd /= std_logic_vector(to_unsigned(0, 5))) then
                        hzd_sig_raw <= '1';
                        PC_SEL <= '1';
                    elsif((ID_Rs1 = MEM_Rd OR ID_Rs2 = MEM_Rd) AND MEM_Rd /= std_logic_vector(to_unsigned(0, 5))) then
                        hzd_sig_raw <= '1';
                        PC_SEL <= '1';
                    elsif((ID_Rs1 = WB_Rd OR ID_Rs2 = WB_Rd) AND WB_Rd /= std_logic_vector(to_unsigned(0, 5))) then
                        hzd_sig_raw <= '1';
                        PC_SEL <= '1';
                    else
                        hzd_sig_raw <= '0';
                        PC_SEL <= '0';
                    end if;
                end if;
            --hzd_sig_ctrl <= '0';
            --hzd_sig_jmp <= '0';
            --PC_SEL <= '0';  -- qeusta assegnazione fa si che pcsel stia sempre a 0 attenzione.
            end if;  
        end if;
    end process;
   

end architecture beh;
