library ieee;
use ieee.std_logic_1164.all;
USE work.INSTR_CODES.ALL;

entity IR0 is
    generic ( RegNbit: integer );
    port (  clk:    in  std_logic;
            rst:    in  std_logic;
            en:     in  std_logic;
            fromHU: in  std_logic;
            hzd_sig_jmp: in std_logic;
            I:      in  std_logic_vector(RegNbit-1 downto 0);
            Q:      out std_logic_vector(RegNbit-1 downto 0) );
end IR0;


architecture behavioral of IR0 is
    signal mem: std_logic_vector(RegNbit-1 downto 0);
begin
    
    general_ref: process (clk, en)
    begin

        if( rising_edge(clk) ) then
            if( rst = '1' ) then --synchronous reset 
                Q <= (others => '0') ;
            ELSIF ( en = '1' ) then
                Q <= I;
                mem <= I;
                if(fromHU = '1') then
                    Q <= mem;
                    mem <= mem;
                   
                end if;
                
            end if;
        end if;
    end process;

end behavioral;
