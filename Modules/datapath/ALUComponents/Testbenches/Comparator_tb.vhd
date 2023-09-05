library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity tb is
end entity;


architecture test of tb is

    component Comparator is
        generic(
            Nbit: integer
        );
        port(
            Inp:	In	std_logic_vector(Nbit-1 downto 0); --input from p4adder
			Cout:	In	std_logic; --input from p4 adder
            A_31:      In std_logic;
            B_31:      In std_logic;
            res:    Out std_logic_vector(4 downto 0) --output
        );
    end component;

    signal Inp_s: std_logic_vector(Nbit-1 downto 0);
    signal Cout_s: std_logic;
    signal A31_s, B31_s: std_logic;
    signal res_s: std_logic_vector(4 downto 0);     
begin

    Comp: comparator
    generic map(Nbit)
    port map(
        Inp => Inp_s,
        Cout => Cout_s,
        A_31 => A31_s,
        B_31 => B31_s,
        res => res_s
    );

    test: process
    begin
        Inp_s <= "00000000000000000000000000000000";       -- A=B 
        Cout_s <= '0';
        A31_s <= '0'; 
        B31_s <= '0';
        wait for 5 ns;
        Inp_s <= "00000000000000000000000000000000";        -- A>=B 
        Cout_s <= '1';
        A31_s <= '0'; 
        B31_s <= '0';      

    wait;
    end process;

end architecture test;