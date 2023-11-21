library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity RCA is 
	generic (NbitRca: integer );
	Port (	
			A:	In	std_logic_vector(NbitRca-1 downto 0);
			B:	In	std_logic_vector(NbitRca-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(NbitRca-1 downto 0);
			Co:	Out	std_logic);

end RCA; 


architecture BEHAVIORAL of RCA is
begin

    Process(A,B, Ci)
	Variable A7, B7, S7: std_logic_vector(32 downto 0);

	Begin
		A7 := '0' & A; --concatinates a '0' bit to the A std_logic_vector
		B7 := '0' & B; --concatinates an additional bit equal to '0' to the B 
					   --logicalvector
		S7 := A7 + B7 + Ci;
		S <= S7(31 downto 0); 
		Co<= S7(32);
	End Process;


  S <= (A + B) ;

end BEHAVIORAL;



--configuration CFG_RCA_BEHAVIORAL of RCA is
--  for BEHAVIORAL 
--  end for;
--end CFG_RCA_BEHAVIORAL;
