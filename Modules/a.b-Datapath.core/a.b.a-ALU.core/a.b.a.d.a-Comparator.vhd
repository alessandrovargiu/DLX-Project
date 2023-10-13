library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Comparator is 
    generic (
        Nbit: integer := 32
    );
	Port (	SUB:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic; --input from p4 adder
            A_31:      In std_logic; 
            B_31:      In std_logic; 
            res:    Out std_logic_vector(7 downto 0) --output
    );
			
end Comparator; 

architecture beh of Comparator is 
    signal Z,C: std_logic;
    signal tmp: std_logic_vector(Nbit-1 downto 0); 
begin
    	
   -- Stage1: process(SUB)
    	--begin 
      --  tmp(0) <= SUB(0);
    	--nor_loop: for i in 1 to Nbit-1 loop
        --    tmp(i) <= tmp(i-1) nor SUB(i);
       -- end loop;
    --end process;
    		Z <= '1' when SUB = std_logic_vector(to_unsigned(0, Nbit)) else '0';
                       -- 1 bit output of NOR gate
    		C <= Cout xor (A_31 xor B_31);  -- if not signed int don t work
	--end process;

            
    Stage2: process(Z,C)
    begin 
        --res(0) <= not Z; -- A!=B
        res(0) <= Z;                -- A=B
        res(1) <= C ;                -- A>=B
        res(2) <= (not Z) and C;    -- A>B
        res(3) <= not C;            -- A<B
        res(4) <= (not C) or Z;     -- A<=B

        --if the operands are considered to be unsigned
        if( (A_31 xnor B_31) = '1' ) then --if 1 outcome is like the signed case
            res(5) <= C; --A >= B
            res(6) <= (not Z and C); --A >  B
            res(7) <= not C ; --A < B
        
        --if the xnor gives 0 the output will be opposite to signed case
        else
            res(5) <= not C; -- A >= B
            res(6) <= not ( (not Z) and C) ; -- A > B
            res(7) <=  C ; -- not (not C) -- A < B

        end if;   

    end process;
end architecture beh;