library ieee;
use ieee.std_logic_1164.all;

entity sgn_extender is
    generic ( NbitIn: integer;  --is either 16 (for immediate instruction ) or 26 for jump instruction type
              NbitImm: integer ); --usually 32
    port ( signedOrUnsigned:  in std_logic; 
           se_in:             in std_logic_vector(NbitIn-1 downto 0);
           se_out:            out std_logic_vector(NbitImm-1 downto 0) 
         );
end sgn_extender ;

architecture Behavioral of sgn_extender is

begin 


FormingOutput : for i in 0 to (NbitImm-1) generate  
    
    LSBsOfOut : if i < NbitIn generate
        LSBs : se_out(i) <= se_in(i);
    end generate LSBsOfOut;
    
    MSBsOfOut:  if NbitIn-1 < i and i< NbitImm generate 
        MSBs : se_out(i) <= signedOrUnsigned; --se e' signed , gli MSBs li metto a 1. 
    end generate MSBsOfOut;

end generate FormingOutput;


end Behavioral ;


