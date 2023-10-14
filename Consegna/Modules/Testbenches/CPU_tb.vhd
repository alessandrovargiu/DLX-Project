LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;

entity CPUtb is
end CPUtb;


architecture CPUtest of CPUtb is

    component CPU is
        PORT (              
        clk : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
        reset : IN STD_LOGIC; -- Reset Signal: Asyncronous Active Low (Negative)
        enable: in std_logic
        --Instr_in : IN std_logic_vector (Nbit-1 downto 0);
    );
END component;

signal clk_s, reset_s, enable_s : std_logic;
--signal Instr_in_s :  std_logic_vector (Nbit-1 downto 0);

begin 

ClkProcess: PROCESS
    BEGIN
       Clk_s <= '0';
       WAIT FOR 0.5 ns;
       Clk_s <= '1'; 
       WAIT FOR 0.5 ns;
    END PROCESS;

    UUT: CPU
    port map(
        clk => clk_s,
        reset => reset_s,
        enable => enable_s
        --Instr_in => Instr_in_s
    );
    
    Reset_s <= '1', '0' after 1.5 ns;
    enable_s <= '1' ;

    test: process
    begin
        
        

        wait for 50 ns;
        wait;

    end process;
    end architecture;