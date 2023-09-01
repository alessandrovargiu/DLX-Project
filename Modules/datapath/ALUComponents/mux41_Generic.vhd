library IEEE;
use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity mux41_GENERIC is
		Generic	(	
			Nbit: integer:= 31
		);
		Port 	(	
					A:		In	std_logic_vector(N-1 downto 0);
					B:		In	std_logic_vector(N-1 downto 0);
					C:		In	std_logic_vector(N-1 downto 0);
					D:		In	std_logic_vector(N-1 downto 0);
					SEL:	In	std_logic_vector(1 downto 0);
					E:		Out	std_logic_vector(N-1 downto 0));
end mux41_GENERIC;

architecture BEH of MUX41_GENERIC is

begin

		process (SHIFTER_OUT, ADD_OUT, CMP_OUT, LOGICALS_OUT, SEL)
		begin
		case SEL is
			when "00" =>
				Y<=A; --add
			when "01" =>
				Y<=B; --shifter
			when "10" =>
				Y<=C; --comparator
			when others =>
				Y<=D; --logic
		end case;
		end process;

end BEH;