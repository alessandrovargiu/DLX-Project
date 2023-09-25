LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;

entity tb is
end tb;


architecture test of tb is

    component CPU is
        PORT (              
        clk : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
        reset : IN STD_LOGIC -- Reset Signal: Asyncronous Active Low (Negative)
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
        reset => reset_s
        --Instr_in => Instr_in_s
    );

    test: process
    begin

        enable_s <= '1' after 1.5 ns;
        reset_s <= '1';
        wait for 1 ns;
        reset_s <= '0';
        wait for 50 ns;
        wait;


    end process;
    end architecture;