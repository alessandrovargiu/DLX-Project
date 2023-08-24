library ieee;
use ieee.std_logic_1164.all;

entity sgn_extender is
    port ( se_in    : in std_logic_vector(15 downto 0) );
         ( se_out   : out std_logic_vector(31 downto 0) 
         );
end sgn_extender ;

architecture Behavioral of sgn_exteder is

begin 

    se_out <= x"0000" & se_in(15) = '0' else   
              x"FFFF" & se_in ; 

end Behavioral ;
