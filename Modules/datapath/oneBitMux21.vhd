library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
--use WORK.constants.all; -- libreria WORK user-defined

entity oneBitMux21 is
	Port (	input1:		In	std_logic;
			input2:		In	std_logic;
			Sel:		In	std_logic;
			Y:			Out	std_logic );
end oneBitMux21;

architecture BEHAVIORAL of oneBitMux21 is

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
