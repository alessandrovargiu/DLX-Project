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

    fetch: process(IR_ID, IR_EX, IR_MEM)
    begin
        ID_Rs1 <= (others =>'0');
        ID_Rs2 <= (others =>'0');
        EX_Rd <= (others =>'0');
        MEM_Rd <= (others =>'0');
        if(IR_ID(Nbit-1 downto Nbit-6) = RTYPE) then
            ID_Rs1 <= IR_ID(Nbit-7 downto Nbit-11);
            ID_Rs2 <= IR_ID(Nbit-12 downto Nbit-16);
            ID_Rd <= IR_ID(Nbit-17 downto Nbit-21);
        elsif(IR_ID(Nbit-1 downto Nbit-6) /= NOP) then
            ID_Rs1 <= IR_ID(Nbit-7 downto Nbit-11);
            ID_Rs2 <= "00000";
            ID_Rd <= IR_ID(Nbit-12 downto Nbit-16);
            if(IR_ID(Nbit-1 downto Nbit-6) = ITYPE_STW) then
                ID_Rs1 <= IR_ID(Nbit-12 downto Nbit-16);
                ID_Rd <= IR_ID(Nbit-7 downto Nbit-11);
            end if;
        end if;
        if(IR_EX(Nbit-1 downto Nbit-6) = RTYPE) then 
            EX_Rd <= IR_EX(Nbit-17 downto Nbit-21);
        elsif(IR_EX(Nbit-1 downto Nbit-6) /= NOP) then
            EX_Rd <= IR_EX(Nbit-12 downto Nbit-16);
            if(IR_EX(Nbit-1 downto Nbit-6) = ITYPE_STW) then
                EX_Rd <= IR_EX(Nbit-7 downto Nbit-11);
            end if;
        end if;
        if(IR_MEM(Nbit-1 downto Nbit-6) = RTYPE) then 
            MEM_Rd <= IR_MEM(Nbit-17 downto Nbit-21);
        elsif(IR_MEM(Nbit-1 downto Nbit-6) /= NOP) then
            MEM_Rd <= IR_MEM(Nbit-12 downto Nbit-16);
            if(IR_MEM(Nbit-1 downto Nbit-6) = ITYPE_STW) then
                MEM_Rd <= IR_MEM(Nbit-7 downto Nbit-11);
            end if;
        end if;
        
    end process;

    --pipe: process(clk)
    --begin
    --    if(rst = '0' AND rising_edge(clk)) then
    --        EX_Rd <= "00000";
    --        MEM_Rd <= "00000";
    --        WB_Rd <= "00000";
    --        if(IR_EX(Nbit-1 downto Nbit-6) /= NOP) then
    --            EX_Rd <= ID_Rd;
    --        end if;
    --        --if(IR_MEM(Nbit-1 downto Nbit-6) /= NOP) then
    --            MEM_Rd <= EX_Rd;
    --        --end if;
    --       -- if(IR_WB(Nbit-1 downto Nbit-6) /= NOP) then
    --            WB_Rd <= MEM_Rd;
    --       -- end if; 
    --    end if;
    --end process;
    
    ------------------- RAW hazard detection ------------------
    -- hazard check done on ID stage 
    -- possibility of forwarding implementation in the future
    -- IR opcode MSB is 1 for JUMPS, 0 for all other instructions which are subject to RAW hazards

    RAW: process (clk)
    begin
          if(rst = '0' AND falling_edge(clk)) then
            if (IR_ID(Nbit-1 downto Nbit-6) = JTYPE_JMP and BranchStatus = '0') then 
                hzd_sig_jmp <= '1';
                PC_SEL <= '1';
            elsif (IR_ID(Nbit-1 downto Nbit-6) = JTYPE_JAL and BranchStatus = '0') then
                hzd_sig_jmp <= '1';  
                PC_SEL <= '1';
            elsif (IR_ID(Nbit-1 downto Nbit-6) = ITYPE_JR and BranchStatus = '0') then
                if (ID_Rs1 = EX_Rd OR ID_Rs1 = MEM_Rd ) then
                    hzd_sig_raw <= '1';
                    PC_SEL <= '1';
                else
                    hzd_sig_raw <= '0';
                    hzd_sig_jmp <= '1';  
                    PC_SEL <= '1';
                end if;
            elsif(branchStatus = '1' AND (IR_EX(Nbit-1 downto Nbit-6) = ITYPE_BEQZ or IR_EX(Nbit-1 downto Nbit-6) = ITYPE_BNEZ) ) then
                hzd_sig_ctrl <= '1';
                PC_SEL <= '0';
            else
                hzd_sig_raw <= '0';
                hzd_sig_ctrl <= '0';
                hzd_sig_jmp <= '0';
                PC_SEL <= '0';  
                if(((IR_ID(Nbit-1 downto Nbit-6) /= NOP) AND IR_EX(Nbit-1 downto Nbit-6) /= NOP) OR ((IR_ID(Nbit-1 downto Nbit-6) /= NOP) AND IR_MEM(Nbit-1 downto Nbit-6) /= "000010") ) then  --OR ((IR_ID(Nbit-1 downto Nbit-6) /= "000010") ) AND IR_WB(Nbit-1 downto Nbit-6) /= "000010"
                    if((ID_Rs1 = EX_Rd OR ID_Rs2 = EX_Rd) AND EX_Rd /= std_logic_vector(to_unsigned(0, 5))) then
                        hzd_sig_raw <= '1';
                        PC_SEL <= '1';
                    elsif((ID_Rs1 = MEM_Rd OR ID_Rs2 = MEM_Rd) AND MEM_Rd /= std_logic_vector(to_unsigned(0, 5))) then
                        hzd_sig_raw <= '1';
                        PC_SEL <= '1';
                    else
                        hzd_sig_raw <= '0';
                        PC_SEL <= '0';
                    end if;
                else
                    hzd_sig_raw <= '0';
                    PC_SEL <= '0';
                end if;
            end if;
        end if;
            
    end process;
   

end architecture beh;