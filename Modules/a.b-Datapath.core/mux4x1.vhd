library ieee;
use ieee.std_logic_1164.all;

entity MUX41 is
	    Generic ( MuxNbit: integer );
	    Port (	input1:		In	std_logic_vector(MuxNbit-1 downto 0); --unsigned input of 16 bits
			    input2:		In	std_logic_vector(MuxNbit-1 downto 0); --signed input of 16 bits
                input3:     IN  std_logic_vector(MuxNbit-1 downto 0); --unsigned input of 26 bits
                input4:     in  std_logic_vector(MuxNbit-1 downto 0); --signed input of 26 bits
			    Sel:		In	std_logic_vector(2-1 downto 0); --these selections will be coming from the CU that will tell
			    Y:			Out	std_logic_vector(MuxNbit-1 downto 0));
end MUX41;

architecture behavioral of MUX41 is

begin

process(Sel, input1, input2, input3 )

begin

case (Sel) is

	when "00" =>	Y <= input1;
	when "01" =>	Y <= input2;
	--when "10" =>	Y <= input3;
	when "10" =>	Y <= (others => '0'); -- in nop case: reg0 + 0 will give 0.
	when "11" =>	Y <= input4;

	when others =>	Y <= input1;

end case;

	end process;

end behavioral;