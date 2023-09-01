library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.constants.all;

entity tb is
end tb;


architecture test of tb is

    component Shifter is
        generic (
            Nbit: integer
        );
	Port (	A:	In	std_logic_vector(Nbit-1 downto 0); --input
			B:	In	std_logic_vector(5-1 downto 0); --input bits shift , 5 o 6 bit?
            OP:  In  std_logic_vector(2-1 downto 0); -- input left or right
            S:  Out std_logic_vector(Nbit-1 downto 0) --output 
    );
    end component;

    signal A_s: std_logic_vector(Nbit-1 downto 0);
    signal B_s: std_logic_vector(5-1 downto 0);
    signal OP_s: std_logic_vector(2-1 downto 0);
    signal S_s: std_logic_vector(Nbit-1 downto 0);
begin

    shft: Shifter
    generic map(Nbit => Nbit)
    port map (
        A => A_s,
        B => B_s,
        OP => OP_s,
        S => S_s
    );

    test: process
    begin
        --------------- logic left shifting ------------------
        A_s <= "00000000000000000011100000000000";
        B_s <= "00010";    --two positions
        OP_s <= "00";      --logic left
        wait for 5 ns;     
        A_s <= "10000000000000000011100000000000";
        B_s <= "01010";    --ten positions
        OP_s <= "00";      --logic left
        wait for 5 ns;
        ---------------- logic right shifting -------------------
        A_s <= "00000000000000000011100000000000";
        B_s <= "11110";    --30 positions
        OP_s <= "01";      --logic right 
        wait for 5 ns;
        ----------------  Shift Right Arithmetic ----------------
        A_s <= "11111111111000111111111111111100";
        B_s <= "00101";
        OP_s <= "10";
        wait for 5 ns;

        wait;
        
    end process;




end test;


