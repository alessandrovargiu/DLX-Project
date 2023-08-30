library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
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

	process(Sel)

	begin

		if( Sel = '1') then
			Y <= input2;
		else 
			Y <= input1;
		end if;

	end process;

end BEHAVIORAL;


