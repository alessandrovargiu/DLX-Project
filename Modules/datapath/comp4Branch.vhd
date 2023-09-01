library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comp4Branch is
    generic(Nbit : integer);
    port(   A:    in  unsigned;
            cond: out std_logic );
end comp4Branch;

architecture behavioral of comp4Branch is
begin

    comp: process( A )

    begin

        if ( A =  0 ) then
        cond <= '1';

        else 
        cond <= '0';

        end if;
        
    end process;

end behavioral;