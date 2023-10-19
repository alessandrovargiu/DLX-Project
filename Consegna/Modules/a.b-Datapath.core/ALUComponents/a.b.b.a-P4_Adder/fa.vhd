library ieee; 
use ieee.std_logic_1164.all; 

entity FA is 
        --generic ( DFAS: time := 0 ns;
		  --		  DFAC: time := 0 ns);

		Port (	A:	In	std_logic;
				B:	In	std_logic;
				Ci:	In	std_logic;
				S:	Out	std_logic;
				Co:	Out	std_logic);
end FA; 

architecture P4_FA_BEHAVIORAL of FA is

begin

  S  <= A xor B xor Ci; --after DFAS;
  Co <= (A and B) or (B and Ci) or (A and Ci);-- after DFAC;
  -- Co <= (A and B) or (B and Ci) or (A and Ci);
  
end P4_FA_BEHAVIORAL;

configuration CFG_FA_BEHAVIORAL of FA is	
  for P4_FA_BEHAVIORAL
  end for;
end CFG_FA_BEHAVIORAL;