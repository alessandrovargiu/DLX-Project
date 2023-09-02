library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
--use WORK.constants.all; -- libreria WORK user-defined

entity oneBitMux21 is
	Port (	in1:		In	std_logic;
			in2:		In	std_logic;
			sel:		In	std_logic;
			oneBitOut:			Out	std_logic );
end oneBitMux21;

architecture BEHAVIORAL of oneBitMux21 is

begin

	process(Sel, in1, in2)

	begin

		case Sel is
			when '1' =>
				oneBitOut <= in1;
			when '0' =>
				oneBitOut <= in2;
			when others =>
				oneBitOut <= 'U';
		end case;

	end process;

end BEHAVIORAL;
