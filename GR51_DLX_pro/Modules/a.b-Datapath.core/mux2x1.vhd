library IEEE;
use IEEE.std_logic_1164.all; 
--use WORK.constants.all; -- libreria WORK user-defined

entity MUX21 is
	Generic ( MuxNbit:	integer); --number of bits of the input
	Port (	input1:		In	std_logic_vector(MuxNbit-1 downto 0);
			input2:		In	std_logic_vector(MuxNbit-1 downto 0);
			Sel:		In	std_logic;
			Y:			Out	std_logic_vector(MuxNbit-1 downto 0));
end MUX21;

architecture BEHAVIORAL of MUX21 is

begin

	process(Sel, input1, input2)

	begin

		case Sel is
			when '1' =>
				Y <= input2;
			when others =>
				Y <= input1;
		end case;

	end process;

end BEHAVIORAL;


