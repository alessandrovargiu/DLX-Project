library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity Shifter is 
    generic (
        Nbit: integer     -- Nbit 32 bit
    );
	Port (	A:	In	std_logic_vector(Nbit-1 downto 0); --input
			B:	In	std_logic_vector(5-1 downto 0); --input bits shift , 5 o 6 bit?
            OP:  In  std_logic_vector(2-1 downto 0); -- input left or right
            S:  Out std_logic_vector(Nbit-1 downto 0) --output 
    );
			
end Shifter; 

architecture beh of Shifter is
    signal mask00,mask08,mask16,mask24,mask : std_logic_vector (Nbit-1+8 downto 0);
begin
    
    level1 : process (A,OP)
    begin
        case OP is
            when "00" => mask00 <= A(Nbit-1 downto 0) & "00000000";   --logic left
                         mask08 <= A(Nbit-1-8 downto 0) & "0000000000000000";
                         mask16 <= A(Nbit-1-16 downto 0) & "000000000000000000000000";
                         mask24 <= A(Nbit-1-24 downto 0) & "00000000000000000000000000000000";
            when "01" => mask00 <= "00000000" & A(Nbit - 1 downto 0); --logic right
                         mask08 <= "0000000000000000" & A(Nbit - 1 downto 8) ;
                         mask16 <= "000000000000000000000000" & A(Nbit - 1 downto 16);
                         mask24 <= "00000000000000000000000000000000" & A(Nbit - 1 downto 24);
            when "10" => mask00 <= (7 downto 0 => A(Nbit-1)) & A;  --Nbit-1 downto (Nbit-8)
                         mask08 <= (15 downto 0 => A(Nbit-1)) & A(Nbit-1 downto 8);
                         mask16 <= (23 downto 0 => A(Nbit-1)) & A(Nbit-1 downto 16);
                         mask24 <= (31 downto 0 => A(Nbit-1)) & A(Nbit-1 downto 24);
            when others => mask00 <= (others=>'0');
                           mask08 <= (others=>'0');
                           mask16 <= (others=>'0');
                           mask24 <= (others=>'0');
        end case;
    end process;
    level2: process (mask00,mask08,mask16,mask24,B)
    begin
        case B(4 downto 3) is
            when "00" => mask <= mask00;
            when "01" => mask <= mask08;
            when "10" => mask <= mask16;
            when "11" => mask <= mask24;
            when others => mask <= (others=>'X');
        end case;
    end process;
    level3: process (B,mask)
    begin
        case B(2 downto 0) is
            when "000" => S <= mask((Nbit - 1) + 8 downto 8);
            when "001" => S <= mask((Nbit - 1) + 7 downto 7);
            when "010" => S <= mask((Nbit - 1) + 6 downto 6);
            when "011" => S <= mask((Nbit - 1) + 5 downto 5);
            when "100" => S <= mask((Nbit - 1) + 4 downto 4);
            when "101" => S <= mask((Nbit - 1) + 3 downto 3);
            when "110" => S <= mask((Nbit - 1) + 2 downto 2);
            when "111" => S <= mask((Nbit - 1) + 1 downto 1);
            when others => S <= (others => 'X');
        end case;
    end process;
 end beh;



    



