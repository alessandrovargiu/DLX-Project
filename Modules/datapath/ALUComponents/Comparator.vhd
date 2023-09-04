library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Comparator is 
    generic (

    );
	Port (	Sub:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic; --input from p4 adder
            A:      In std_logic_vector (Nbit-1 downto 0);
            B:      In std_logic_vector (Nbit-1 downto 0);
            res:    Out std_logic_vector(4 downto 0) --output
    );
			
end Comparator; 


architecture beh of Comparator is 
signal Z: std_logic;
signal C: std_logic;
begin
    Stage1: process(Cout,A,B,Sub)
    begin 
        Z <= nor Sum;   --oppure loop if not work as only nor
        C <= Cout xor (A[31] xor B[31]);  -- if not signed int don t work
    end process

    Stage2: process(Z,C)
    begin 
        --res(0) <= not Z; -- A!=B
        res(0) <= Z; -- A=B
        res(1) <= C; -- A>=B
        res(2) <= (not Z) and C; -- A>B
        res(3) <= not C; --A<B
        res(4) <= (not C) or Z; -- A<=B
    end process;
end beh;



