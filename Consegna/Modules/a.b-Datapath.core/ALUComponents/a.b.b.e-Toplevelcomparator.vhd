library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ToplevelComparator is 
    generic (
	Nbit : integer := 32
    );
	Port (	Sub:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic; --input from p4 adder
            A:      In std_logic_vector (Nbit-1 downto 0);
            B:      In std_logic_vector (Nbit-1 downto 0);
            res:    Out std_logic_vector(Nbit-1 downto 0); --output
            op:     In std_logic_vector (2 downto 0)
    );
end ToplevelComparator;
    architecture beh of ToplevelComparator is
        component Comparator is
            Port (	Sub:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic; --input from p4 adder
            A_31:      In std_logic;
            B_31:      In std_logic;
            res:    Out std_logic_vector(7 downto 0) --output
            );
        end component;
    signal res_s5: std_logic_vector (7 downto 0);
    signal res_s1: std_logic;
begin
    comparator1: comparator port map(Sub,Cout,A(31),B(31),res_s5);
    mux: process(op,res_s5)
    begin
    case op is
        when "000" => res_s1 <= res_s5(0);
        when "001" => res_s1 <= res_s5(1);
        when "010" => res_s1 <= res_s5(2);
        when "011" => res_s1 <= res_s5(3);
        when "100" => res_s1 <= res_s5(4);
	    when "101" => res_s1 <= not res_s5(0);
        when "110" => res_s1 <=  res_s5(5);  -- Aunsigned>=Bunsigned
        when "111" => res_s1 <=  res_s5(6);  -- Aunsigned> Bunsigned
		when others => res_s1 <= 'X';
    end case;
    end process;
    res(Nbit-1 downto 1)<=(others=>'0'); -- to extend to Nbit
	res(0)<=res_s1;
end beh;
