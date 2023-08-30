library ieee; 
use ieee.std_logic_1164.all;
use iee.numeric_std.all;

entity ToplevelComparator is 
    generic (

    );
	Port (	Sum:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic --input from p4 adder
            A:      In std_logic_vector (Nbit-1 downto 0);
            B:      In std_logic_vector (Nbit-1 downto 0);
            res:    Out std_logic_vector(Nbit-1 downto 0); --output
            op:     In std_logic_vector (2 downto 0)
    );

    architecture beh of ToplevelComparator is
        component Comparator is
            Port (	Sum:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic; --input from p4 adder
            A:      In std_logic_vector (Nbit-1 downto 0);
            B:      In std_logic_vector (Nbit-1 downto 0);
            res:    Out std_logic_vector(4 downto 0) --output
            );
        end component;
    signal res_s5: std_logic_vector (4 downto 0);
    signal res_s1: std_logic;
begin
    comparator: comparator port map(Sum,Cout,A,B,res_s5)
    mux: process(op,res_s5)
    case op is
        when "000" => res_s1 <= res_s5(0);
        when "001" => res_s1 <= res_s5(1);
        when "010" => res_s1 <= res_s5(2);
        when "011" => res_s1 <= res_s5(3);
        when "100" => res_s1 <= res_s5(4);
        when others => res_s1 <= "X";
    end case;
    res(N-1 downto 1)<=(others=>'0'); -- to extend to Nbit
	res(0)<=res_s1;
end beh;




			
end ToplevelComparator; 