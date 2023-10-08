library ieee;
use ieee.std_logic_1164.all;

entity myregister is
    generic ( RegNbit: integer );
    port (  clk:    in  std_logic;
            rst:    in  std_logic;
            --hzd_sig_ctrl: in std_logic;
            en:     in  std_logic;
            I:      in  std_logic_vector(RegNbit-1 downto 0);
            Q:      out std_logic_vector(RegNbit-1 downto 0) );
end myregister;


architecture behavioral of myregister is
    signal mem: std_logic_vector(RegNbit-1 downto 0);
begin
    
    general_ref: process (clk, en)
    begin

        if( rising_edge(clk) ) then
            if( rst = '1' ) then --synchronous reset 
                Q <= (others => '0') ;
            ELSIF ( en = '1' ) then
                Q <= I ;
                mem <= I;
                --if(hzd_sig_ctrl = '1') then
                --Q <= (others => '0') ;
                --end if;
            elsif ( en = '0' ) then
                Q <= mem ;               -- memory state when enable = 0 and rst = 0 (used in stalls)
            end if;
        end if;
    end process;

end behavioral;