library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
--use work.myTypes.all;

entity dp_test2 is
end dp_test2;

architecture TEST of dp_test2 is

    constant Nbit: integer := 32;
    constant controlNbit: integer := 25;
    constant addressNbit: integer := 32; --number of bits used by the addresses of the instruction memory

    constant CWNbitsID: integer  :=5;
    constant CWNbitsEX: integer  :=12;
    constant CWNbitsMEM: integer :=3;
    constant CWNbitsWB: integer  :=5;

    constant CWIdBitsADDI: std_logic_vector(CWNBitsID-1 downto 0) := "10101" ;
    constant CWExBitsADDI: std_logic_vector(CWNBitsEX-1 downto 0) := "110100000000";
    constant CWMemBitsADDI: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsADDI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsSUBI: std_logic_vector(CWNBitsID-1 downto 0) := "10101";
    constant CWExBitsSUBI: std_logic_vector(CWNBitsEX-1 downto 0) := "110100010000";
    constant CWMemBitsSUBI: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsSUBI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsORI: std_logic_vector(CWNBitsID-1 downto 0) := "10100";
    constant CWExBitsORI: std_logic_vector(CWNBitsEX-1 downto 0) := "110101111100";
    constant CWMemBitsORI: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsORI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsADD: std_logic_vector(CWNBitsID-1 downto 0) := "11111";
    constant CWExBitsADD: std_logic_vector(CWNBitsEX-1 downto 0) := "101100000000";
    constant CWMemBitsADD: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsADD: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWidBitsJTYPE_JMP: std_logic_vector(CWNBitsID-1 downto 0) := "00111";
    constant CWExBitsJTYPE_JMP: std_logic_vector(CWNBitsEX-1 downto 0) := "010100000001";
    constant CWMemBitsJTYPE_JMP: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsJTYPE_JMP: std_logic_vector(CWNbitsWB-1 downto 0) := "00000";

    component BasicDP is
    Generic( NbitMem: integer;
             controlNbit: integer;
             addressNbit: integer );
    port(   Clk :        in std_logic;
            rst :        in std_logic;

            fromHU:      in std_logic;
            enable:      in std_logic;
            
            IMdata:      in std_logic_vector(Nbit-1 downto 0);
            controlWord: in std_logic_vector(controlNbit-1 downto 0);
            
            IMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMdata:      inout std_logic_vector(Nbit-1 downto 0)
    );
end component;

    signal Clock: std_logic := '0';
    signal Reset: std_logic := '1';
    signal enable_i: std_logic ;
    signal fromHU_i: std_logic := '0';

    signal IMdata_i, DMdata_i: std_logic_vector(Nbit-1 downto 0);
    signal controlWord_i: std_logic_vector(controlNbit-1 downto 0);
    signal IMaddress_i, DMaddress_i: std_logic_vector(addressNbit-1 downto 0);

    signal currentControlBitsID:  std_logic_vector(CWNbitsID-1 downto 0);
    signal currentControlBitsEX:  std_logic_vector(CWNbitsEX-1 downto 0);
    signal currentControlBitsMem: std_logic_vector(CWNbitsMEM-1 downto 0);
    signal currentControlBitsWB:  std_logic_vector(CWNbitsWB-1 downto 0);

begin

        -- instance of DP
       DP: BasicDP
	   generic map (NbitMem => Nbit, controlNbit => controlNbit, addressNbit => addressNbit)
       port map (
                clk => Clock,
                rst => Reset,
                fromHU => fromHU_i,
                enable => enable_i,
                IMdata => IMdata_i,
                controlWord => controlWord_i,
                IMaddress => IMaddress_i,
                DMaddress => DMaddress_i,
                DMdata => DMdata_i
               );
        
        Clock <= not Clock after 1 ns;
	    Reset <= '1', '0' after 2.5 ns;
        enable_i <= '1' after 1.5 ns;

        DPSampleSignals: process

        --IM memory address is expressed on 32 bits
        --

        --Simple Program with no stalls--

        --           
        -- label : addi r1, r0, 1                     corrisponding Imem address x"00000000"   
        --         addi r2, r0, 2                     corrisponding Imem address x"00000004"
        --         subi r3, r0, 1                     corrisponding Imem address x"00000008"
        --         ori  r4, r0, 2                     corrisponding Imem address x"0000000C"
        --         add  r5, r1, r2                    corrisponding Imem address x"00000010"
        -- j label                                    corrisponding Imem address x"00000014"

        begin

        wait for 1 ns;

        ControlWord_i<= (others => '0');

        wait for 2 ns; 
        --FIRST CLK CYCLE after RESET
        IMdata_i <= "00000100000000010000000000000001"; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)

        ControlWord_i<= (others => '0');

        wait for 2 ns;
        --second clk cycle
        IMdata_i <= "00000100000000100000000000000010"; -- instruction bits corresponding to -addi r2, r0, 2- 
        
        ControlWord_i <= CWIdBitsADDI & "000000000000" & "000" & "00000" ;
  	       
        wait for 2 ns;
        --third clock cycle
        IMdata_i <= "00001100000000110000000000000001"; -- instruction bits corresponding to -subi r3, r0, 1- (opcode assumed for subi is 00011)
        
        ControlWord_i <= CWIDbitsADDI & CWExBitsADDI & "000" & "00000"  ;
        
        wait for 2 ns;
        --forth clock cycle
        IMdata_i <= "00010100000001000000000000000010"; -- instruction bits corresponding to -or r4, r0, 2- 	
        
        controlword_i <= CWIdbitsSUBI & CWexbitsADDI & CWMemBitsADDI & "00000" ;

        wait for 2 ns;
        --fifth clock cycle
        IMdata_i <= "00000000001000100010100000000000"; --instruction bits corresponding to 5th instruction: -add r5, r1, r2-  (opcode assumed for the add Rtype is 000000 and related FUNC is 00000000000 )
        
        controlword_i <= CWIdBitsORI & CWExBitsSUBI & CWMemBitsADDI & CWWBBitsADDI;

        wait for 2 ns;
        --sixth clock cycle
        IMdata_i <= "10000011111111111111111111101000"; --instruction bits corresponding to 6th instruction: -j label- the offset in this case is -20 since label is at a prior memory address.
                                                        -- (-20 as a signed binary rapresentation on 26 bits: 11 1111 1111 1111 1111 1110 1100)
        controlWord_i <= CWIdBitsADD & CWExBitsORI & CWMemBitsSUBI & CWWBBitsADDI ;
         
        wait for 2 ns;
        --seventh clock cycle

        controlWord_i <= CWidBitsJTYPE_JMP & CWExBitsADD & CWMemBitsORI & CWWBBitsSUBI ;  

        wait for 2 ns;

        --eith clock cycle

        controlWord_i <= "00000" & CWexBitsJTYPE_JMP & CWMemBitsADD & CWWBBitsORI ;

        wait for 2 ns;

        --ninth clock cycle
        controlword_i <= "00000" & "000000000000" & CWmembitsJTYPE_JMP & CWWbbitsAdd ;
        wait for 2 ns;


        IMdata_i <= "00000100000000010000000000000001"; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)

        controlword_i <= "00000" & "000000000000" & "000" & CWwbBitsJTYPE_JMP ;

        wait for 2 ns;

        IMdata_i <= "00000100000000100000000000000010"; -- instruction bits corresponding to -addi r2, r0, 2- 
        
        ControlWord_i <= CWIdBitsADDI & "000000000000" & "000" & "00000" ;

        wait for 2 ns;

        IMdata_i <= "00001100000000110000000000000001"; -- instruction bits corresponding to -subi r3, r0, 1- (opcode assumed for subi is 00011)
       
        ControlWord_i <= CWIDbitsADDI & CWExBitsADDI & "000" & "00000"  ;

        wait for 2 ns;

        IMdata_i <= "00010100000001000000000000000010"; -- instruction bits corresponding to -or r4, r0, 2- 	

        controlword_i <= CWIdbitsSUBI & CWexbitsADDI & CWMemBitsADDI & "00000" ;
        
        wait for 2 ns;

        IMdata_i <= "00000000001000100010100000000000"; --instruction bits corresponding to 5th instruction: -add r5, r1, r2-  (opcode assumed for the add Rtype is 000000 and related FUNC is 00000000000 )
        
        controlword_i <= CWIdBitsORI & CWExBitsSUBI & CWMemBitsADDI & CWWBBitsADDI;
        
        wait for 2 ns;
        --and the story repeats 
        
        wait;

        end process;

end TEST;