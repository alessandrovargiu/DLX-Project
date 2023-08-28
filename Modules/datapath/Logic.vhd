library ieee; 
use ieee.std_logic_1164.all;
use iee.numeric_std.all; 

entity Logic is 
    generic (

    );
	Port (	A:	In	std_logic_vector(Nbit-1 downto 0); --input
			B:	In	std_logic_vector(Nbit-1 downto 0); --input
			S:	In	std_logic_vector(4-1 downto 0); --opcode for logic
            C:  Out std_logic_vector(Nbit-1 downto 0); --output
            
    );
			
end Logic; 

architecture structural of Logic is

begin
    signal c0,c1,c2,c3 : std_logic_vector (Nbit-1 downto 0)
    row1: process ( A,B,S)
    first_row : for i in 0 to Nbit - 1 loop

        c0(i) <= not (S(0) and (not A(i)) and (not B(i)));
        c1(i) <= not (S(1) and (not A(i)) and B(i));
        c2(i) <= not (S(2) and A(i) and (not B(i)));
        c3(i) <= not (S(3) and A(i) and B(i));
  
      end loop;
    row2: process (c0,c1,c2,c3)
    begin
        second_row : for i in 0 to Nbit - 1 loop

            C(i)<=not(c0(i) and c1(i) and c2(i) and c3(i));
      
          end loop;
    end process;
        end structural;



