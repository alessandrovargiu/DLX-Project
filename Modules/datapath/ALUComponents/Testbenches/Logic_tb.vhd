library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.constants.all;

entity tb is
end tb;


architecture test of tb is

    component Logic is
        generic(
            Nbit: integer
        );
        port(
            A: in std_logic_vector(Nbit-1 downto 0);
            B:	In	std_logic_vector(Nbit-1 downto 0); --input
			S:	In	std_logic_vector(4-1 downto 0); --opcode for logic (know as selectN from lecture notes)
            C:  Out std_logic_vector(Nbit-1 downto 0) --output
        );
    end component;

    signal A_s: std_logic_vector(Nbit-1 downto 0);
    signal B_s: std_logic_vector(Nbit-1 downto 0);
    signal C_s: std_logic_vector(Nbit-1 downto 0);
    signal S_s: std_logic_vector(4-1 downto 0);

begin

    logical: Logic
    generic map(Nbit => NBIT)
    port map(
        A => A_s,
        B => B_s,
        S => S_s,
        C => C_s
    );

    test: process
    begin
        
        A_s <= "00000000000000000001100000000000";
        B_s <= "00000000000000000010100000000000";
        S_s <= "1000";      -- AND
        wait for 5 ns;
        S_s <= "0111";      -- NAND
        wait for 5 ns;
        S_s <= "1110";      -- OR
        wait for 5 ns;
        S_s <= "0001";      -- NOR
        wait for 5 ns;
        S_s <= "0110";      -- XOR
        wait for 5 ns;
        S_s <= "1001";      -- XNOR
        wait for 5 ns;
    wait;
    end process;

end architecture test;







