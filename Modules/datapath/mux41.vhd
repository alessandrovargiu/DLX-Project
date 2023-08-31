library ieee;
library ieee.std_logic_vector_1164.all;

entity MUX41 is
	    Generic ( MuxNbit );
	    Port (	input1:		In	std_logic_vector(ImmField1Nbit-1 downto 0); --unsigned input of 16 bits
			    input2:		In	std_logic_vector(ImmField1Nbit-1 downto 0); --signed input of 16 bits
                input3:     IN  std_logic_vector(ImmField2Nbit-1 downto 0); --unsigned input of 26 bits
                input4:     in  std_logic_vector(ImmField2Nbit-1 downto 0); --signed input of 26 bits
			    Sel:		In	std_logic_vector(2-1 downto 0); --these selections will be coming from the CU that will tell
			    Y:			Out	std_logic_vector(MuxNbit-1 downto 0));
end MUX41;

architecture behavioral of MUX41

begin

process(Sel)

	begin

		if( Sel = "00" ) then
			Y <= input1;
		
        else if (Sel = "01" ) then
			Y <= input2;

        else if (Sel = "10" ) then
            Y <= input3;

        else 
            Y <= input4;

		end if;

	end process;

end behavioral;