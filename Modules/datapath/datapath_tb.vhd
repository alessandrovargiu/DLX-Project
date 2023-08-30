library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
--use work.myTypes.all;

entity dp_test is
end dp_test;

architecture TEST of dp_test is

    constant: Nbit: integer := 32;
    constant: controlNbit: integer := 13;
    constant: addressNbit: integer := 5;

    component BasicDP is
    Generic( Nbit: integer;
             controlNbit: integer;
             addressNbit: integer );
    port(   Clk :        in std_logic;
            rst :        in std_logic;
            --IMready:     in std_logic; -- leggero dubbio, forse il ready e' input per la CU al posto del DP?
            --DMready:     in std_logic; -- leggero dubbio, forse il ready e' input per la CU al posto del DP?
            IMdata:      in std_logic_vector(Nbit-1 downto 0);
            controlWord: in srd_logic_vector(controlNbit-1 downto 0);
            --IMen:      out std_logic;   --Instruction Mem enable signal (enableMem e' output della CU non del DP)
            --DMen:      out std_logic;   --Data Mem enable signal        (enableMem e' output della CU non del DP)
            --DM1R0W:    out std_logic;   --when bit is 0--> writing to data mem, when bit is 1--> reading from mem   (ripensandoci anche questo sembra un output dalla CU)
            IMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMdata:      inout std_logic_vector(Nbit-1 downto 0);
    );
end component;

    signal Clock: std_logic := '0';
    signal Reset: std_logic := '1';

    signal IMdata_i, DMdata_i: std_logic_vector(Nbit-1 downto 0);
    signal controlWord_i: std_logic_vector(controlNbit-1 downto 0);
    signal IMaddress_i, DMaddress_i: std_logic_vector(addressNbit-1 downto 0);
    
begin

        --considered structure of control signal
        --|EN1|RF1|RF2|EN2|S1|S2|ALU1|ALU2|DEST|EN3|RM|WM|S3|EN4|WF1|
        -- instance of DP
       DP: BasicDP
	   generic map (Nbit, controlNbit, addressNbit)
       port map (
                Clock => Clk,
                Reset => rst,
                IMdata => IMdata_i,
                controlWord => controlWord_i,
                IMaddress => IMaddress_i,
                DMaddress => DMaddress_i,
                DMdata => DMdata_i
               );

        Clock <= not Clock after 1 ns;
	    Reset <= '1', '0' after 2 ns;

        DPSampleSignals: process
        begin

        wait for 2 ns;  ----- be careful! the wait statement is ok in test
                        ----- benches, but do not use it in normal processes!
        
        IMdata_i <= "00000100000000010000000000000001" -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)
        controlWord_i <= "110000000000000"   --110.000000.0000.00
        
        wait for 2 ns;
		
        IMdata_i <= "00000100000000100000000000000010" -- instruction bits corresponding to -addi r2, r0, 2- 
        controlWord_i <= "110100000000000"
        wait for 2 ns;

		IMdata_i <= "00001100000000110000000000000001" -- instruction bits corresponding to -subi r3, r0, 1- (opcode assumed for subi is 00011)
        controlWord_i <= "1101"
        wait for 2 ns;
		
		IMdata_i <= "00001100000001000000000000000010" -- instruction bits corresponding to -subi r4, r0, 2- 
        controlWord_i <= ""

        wait for 2 ns;
		
        IMdata_i <= "00000000001000100010100000000000" --instruction bits corresponding to -add r5, r1, r2-  (opcode assumed for the add Rtype is 000000 and related FUNC is 00000000000 )
        wait for 2 ns;
		
		
        wait for 2 ns;

		
        wait for 2 ns;

		
        wait for 2 ns;


        wait;
        end process;

end TEST;