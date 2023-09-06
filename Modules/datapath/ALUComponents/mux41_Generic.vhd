library IEEE;
use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity mux41_GENERIC is
		Generic	(	
			Nbit: integer:= 32
		);
		Port 	(	
					A:		In	std_logic_vector(Nbit-1 downto 0);
					B:		In	std_logic_vector(Nbit-1 downto 0);
					C:		In	std_logic_vector(Nbit-1 downto 0);
					D:		In	std_logic_vector(Nbit-1 downto 0);
					SEL:	In	std_logic_vector(1 downto 0);
					E:		Out	std_logic_vector(Nbit-1 downto 0));
end mux41_GENERIC;

architecture BEH of MUX41_GENERIC is

begin

		process (A, B, C, D, SEL)
		begin
		case SEL is
			when "00" =>
				E<=A; --add
			when "01" =>
				E<=B; --shifter
			when "10" =>
				E<=C; --comparator
			when others =>
				E<=D; --logic
		end case;
		end process;

end BEH;