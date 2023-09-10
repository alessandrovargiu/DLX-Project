library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
--use work.myTypes.all;
--USE work.INSTR_CODES.ALL;

entity dp_test is
end dp_test;

architecture TEST of dp_test is

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
    constant CWExBitsORI: std_logic_vector(CWNBitsEX-1 downto 0) := "110111101100";
    constant CWMemBitsORI: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsORI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsADD: std_logic_vector(CWNBitsID-1 downto 0) := "11111";
    constant CWExBitsADD: std_logic_vector(CWNBitsEX-1 downto 0) := "101100000000";
    constant CWMemBitsADD: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWWbBitsADD: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWidBitsBEQZ: std_logic_vector(CWNBitsID-1 downto 0) := "10101";
    constant CWexBitsBEQZ: std_logic_vector(CWNBitsEX-1 downto 0) := "010100000011"; --3rd bit is dont care
    constant CWmemBitsBEQZ: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWwbBitsBEQZ: std_logic_vector(CWNbitsWB-1 downto 0) := "00000";

    constant CWidBitsBNEZ: std_logic_vector(CWNBitsID-1 downto 0) := "10101";
    constant CWexBitsBNEZ: std_logic_vector(CWNBitsEX-1 downto 0) := "010100000010"; --3rd bit is dont care
    constant CWmemBitsBNEZ: std_logic_vector(CWNbitsMEM-1 downto 0) := "010";
    constant CWwbBitsBNEZ: std_logic_vector(CWNbitsWB-1 downto 0) := "00000";

    --JAL
	constant JAL_DECODE : std_logic_vector(4 downto 0) := "00111";
	constant JAL_EXECUTE: std_logic_vector(11 downto 0) := "011100000001"; 
	constant JAL_MEMORY: std_logic_vector(2 downto 0) := "010";
	constant JAL_WB: std_logic_vector(4 downto 0) := "11111"; --s4 dont care


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


    constant ADDI1BITWISE: std_logic_vector(Nbit-1 downto 0) := "00000100000000010000000000000001" ; -- label: addi r1, r0, 1                      assumed starting memAddress: 0000 0000
    constant ADDI2BITWISE: std_logic_vector(Nbit-1 downto 0) := "00000100000000100000000000000010" ; --        addi r2, r0, 2                      memAddress:                  0000 0004
    constant SUBI1BITWISE: std_logic_vector(Nbit-1 downto 0) := "00001100000000110000000000000000" ; --        subi r3, r0, 0                      memAddress:                  0000 0008
    constant ORI1BITWISE: std_logic_vector(Nbit-1 downto 0) :=  "00010100000001000000000000000010" ;  --       ori  r4, r0, 2                      memAddress:                  0000 000C
    constant ADD1BITWISE: std_logic_vector(Nbit-1 downto 0) :=  "00000000001000100010100000000000" ;  --       add  r5, r1, r2                     memAddress:                  0000 0010
    --constant BEQZ1BITWISE: std_logic_vector(Nbit-1 downto 0) := "00101000010000001111111111101000" ; --        beqz r2, label ; nn dovrebbe saltare                             0000 0014
    --constant BNEZ1BITWISE: std_logic_vector(Nbit-1 downto 0) := "00101100010000001111111111100100" ; --        bnez r2, label ; dovrebbe saltare                                0000 0018
    constant JALBITWISE:   std_logic_vector(Nbit-1 downto 0) := "10000111111111111111111111101000";  --         jal label                   memAddress: 0000 0014

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
        --  addi r1, r0, 1                     corrisponding Imem address x"00000000"   
        --  addi r2, r0, 2                     corrisponding Imem address x"00000004"
        --  subi r3, r0, 1                     corrisponding Imem address x"00000008"
        --  ori  r4, r0, 2                     corrisponding Imem address x"0000000C"
        --  add  r5, r1, r2                    corrisponding Imem address x"00000010"

        begin

        wait for 1 ns;  

        ControlWord_i<= (others => '0');

        wait for 2 ns;
        --in this instant, fetch of first instr

        IMdata_i <= ADDI1BITWISE; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)

        ControlWord_i <= (others => '0');
        

        wait for 2 ns;
	IMdata_i <= ADDI2BITWISE; -- instruction bits corresponding to -addi r2, r0, 2- 	       
        

        ControlWord_i <= CWIdBitsADDI & "000000000000" & "000" & "00000" ;

        wait for 2 ns;

        IMdata_i <= SUBI1BITWISE; -- instruction bits corresponding to -subi r3, r0, 1- (opcode assumed for subi is 00011)

        ControlWord_i <= CWIDbitsADDI & CWExBitsADDI & "000" & "00000"  ;


        wait for 2 ns;
	IMdata_i <= ORI1BITWISE; -- instruction bits corresponding to -ori r4, r0, 2- 	

        controlword_i <= CWIdbitsSUBI & CWexbitsADDI & CWMemBitsADDI & "00000" ;

        wait for 2 ns;
	
        IMdata_i <= ADD1BITWISE; --instruction bits corresponding to 5th instruction: -add r5, r1, r2-  (opcode assumed for the add Rtype is 000000 and related FUNC is 00000000000 )

        controlword_i <= CWIdBitsORI & CWExBitsSUBI & CWMemBitsADDI & CWWBBitsADDI;

        wait for 2 ns;

        --IMdata_i <= BEQZ1BITWISE;
        IMdata_i <=  JALBITWISE;

        controlWord_i <= CWIdBitsADD & CWExBitsORI & CWMemBitsSUBI & CWWBBitsADDI ;
		
        wait for 2 ns; 

        --IMdata_i <= BNEZ1BITWISE;

        --controlWord_i <= CWidBitsBEQZ & CWExBitsADD & CWMemBitsORI & CWWBBitsSUBI ;
        controlWord_i <= JAL_DECODE & CWExBitsADD & CWMemBitsORI & CWWBBitsSUBI ;

        wait for 2 ns;

        --controlWord_i <= CWidBitsBNEZ & CWexBitsBEQZ & CWMemBitsADD & CWWBBitsORI ;
        controlWord_i <= "00000" & JAL_EXECUTE & CWMemBitsADD & CWWBBitsORI ;

        wait for 2 ns;

        --controlword_i <= "00000" & CWexBitsBNEZ & CWmemBitsBEQZ & CWWbbitsAdd ;
        controlword_i <= "00000" & "000000000000" & JAL_MEMORY & CWWbbitsAdd ;

        wait for 2 ns;

        IMdata_i <= ADDI1BITWISE; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)

        --controlword_i <= "00000" & "000000000000" & CWmemBitsBNEZ & CWwbBitsBEQZ ;
        controlword_i <= CWIdBitsADDI & "000000000000" & "000" & JAL_WB ;

        wait for 2 ns;
        
        --IMdata_i <= ADDI1BITWISE; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)

        --controlword_i <= "00000" & "000000000000" & "000" & CWwbBitsBNEZ ;

        wait for 2 ns;

        --IMdata_i <= ADDI2BITWISE; 

        --controlWord_i <= CWIdBitsADDI & "000000000000" & "000" & "00000" ;

        wait for 2 ns;

        wait for 2 ns;

        wait for 2 ns;
        wait;

        end process;

end TEST;