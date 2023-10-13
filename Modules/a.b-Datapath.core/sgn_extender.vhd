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

signal extension1: std_logic_vector(NbitImm-NbitIn-1 downto 0);
signal extension0: std_logic_vector(NbitImm-NbitIn-1 downto 0);

begin 

MsbsOfSignalAre1: for i in 0 to (NbitImm-NbitIn-1) generate
    MsbBits1: extension1(i) <= '1';
end generate MsbsOfSignalAre1;

MsbsOfSignalAre0: for i in 0 to (NbitImm-NbitIn-1) generate
    MsbBits0: extension0(i) <= '0';
end generate MsbsOfSignalAre0;


process( signedOrUnsigned, se_in )

begin 

    if(signedOrUnsigned = '1') then  --if 1, the values is to be interpreted as signed
        if( se_in(NbitIn-1) = '1' ) then
            se_out <= extension1 & se_in ;
        else
            se_out <= extension0 & se_in ;
        end if;
    else 
            se_out <= extension0 & se_in ;
    end if ;

end process;


--OLD not quite right version

--FormingOutput : for i in 0 to (NbitImm-1) generate  
    
--    LSBsOfOut : if i < NbitIn generate

--        LSBs : se_out(i) <= se_in(i);
--    end generate LSBsOfOut;
    
--    MSBsOfOut:  if NbitIn-1 < i and i< NbitImm generate 
--        MSBs : se_out(i) <= signedOrUnsigned; --se e' signed , gli MSBs li metto a 1. 
--    end generate MSBsOfOut;

-- end generate FormingOutput;


end Behavioral ;


