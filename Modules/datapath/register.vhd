library ieee;
library ieee.std_logic_1164.all;

entity register is
    generic ( RegNbit: integer := Nbit);
    port (  clk:    in std_logic;
            rst:    in std_logic;
            en:     in std_logic;
            I:      in std_logic_vector(Nbit-1 downto 0);
            Q:      out ts_logic_vector(Nbit-1 downto 0) );
end register;

architecture behavioral of register is
begin

    general_ref: process (clk, rst)
    begin

        if( rising_edge(clk) ) then

            if( rst = '1' ) then --synchronous reset 
                Q <= (others => '0') ;
            else
            
                if( en = '1' ) then

                    Q <= I ;
            
                end if;

            end if;
        
        end if;

    end process;

end behavioral;