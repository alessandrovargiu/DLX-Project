library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.INSTR_CODES.ALL;
entity HU is
    port (
      clk          : in    std_logic;  -- Clock Signal (rising-edge trigger)
      rst          : in    std_logic;  -- Reset Signal: Asyncronous Active Low (Negative)
      cwd          : in   std_logic_vector(25 downto 0);   -- datapath signals
      hzd_sig      : out std_logic  -- hazard signals
    );
  end entity HU;

  architecture beh of HU is
    --flush_j,flush_b: std_logic;
    begin
        process(cwd)
            hzd_sig <= '0';
            if (cwd = JMP_CWD) then
                hzd_sig <= '1';
            end if;
            if (cwd = JAL_CWD) then
                hzd_sig <= '1';
            end if;
            if (cwd = BEQZ_CWD) then
                if() --- if il segnale che esce dall output allora è preso o no il branch
                    hzd_sig <= '1';
                end if;
            end if;
            if (cwd = BNEZ_CWD) then
                if() --- if il segnale che esce dall output allora è preso o no il branch
                    hzd_sig <= '1';
                end if;
            end if;
        end process;
        


