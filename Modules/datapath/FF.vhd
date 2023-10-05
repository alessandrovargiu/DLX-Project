library ieee;
use ieee.std_logic_1164.all;

entity FlipFlop is
    port (  clk:    in std_logic;
            rst:    in std_logic;
            en:     in std_logic;
            I:      in std_logic;
            Q:      out std_logic);
end FlipFlop;

architecture behavioral of FlipFlop is
begin

    general_ref: process (clk, rst)
    begin
        if( rising_edge(clk) ) then
            if( rst = '1' ) then --synchronous reset 
                Q <= '0' ;
            else
                if( en = '1' ) then
                    Q <= I ;
                end if;
            end if;
        end if;
    end process;

end behavioral;