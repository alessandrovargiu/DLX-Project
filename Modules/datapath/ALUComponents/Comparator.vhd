library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Comparator is 
    generic (
        Nbit: integer
    );
	Port (	Inp:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic; --input from p4 adder
            A_31:      In std_logic; 
            B_31:      In std_logic; 
            res:    Out std_logic_vector(4 downto 0) --output
    );
			
end Comparator; 

architecture beh of Comparator is 
    signal Z,C: std_logic;
    signal tmp: std_logic_vector(Nbit-1 downto 0); 
begin

    Stage1: process(Cout, A_31, B_31, Inp)
    begin 
        tmp(0) <= Inp(0);
        nor_loop: for i in 1 to Nbit-1 loop
            tmp(i) <= tmp(i-1) nor Inp(i);
        end loop;

    end process;

    Z <= tmp(Nbit-1);                    -- 1 bit output of NOR gate
    C <= Cout xor (A_31 xor B_31);  -- if not signed int don t work
            
    Stage2: process(Z,C)
    begin 
        --res(0) <= not Z; -- A!=B
        res(0) <= Z;                -- A=B
        res(1) <= C;                -- A>=B
        res(2) <= (not Z) and C;    -- A>B
        res(3) <= not C;            -- A<B
        res(4) <= (not C) or Z;     -- A<=B
    end process;
end architecture beh;



