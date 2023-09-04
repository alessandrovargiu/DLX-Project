library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
--use work.myTypes.all;

entity dp_test is
end dp_test;

architecture TEST of dp_test is

    constant Nbit: integer := 32;
    constant controlNbit: integer := 25;
    constant addressNbit: integer := 32; --number of bits used by the addresses of the instruction memory

    constant CWNbitsID: integer  :=5;
    constant CWNbitsEX: integer  :=10;
    constant CWNbitsMEM: integer :=5;
    constant CWNbitsWB: integer  :=5;

    constant CWIdBitsADDI: std_logic_vector(CWNBitsID-1 downto 0) := "10101" ;
    constant CWExBitsADDI: std_logic_vector(CWNBitsEX-1 downto 0) := "1101000000";
    constant CWMemBitsADDI: std_logic_vector(CWNbitsMEM-1 downto 0) := "01000";
    constant CWWbBitsADDI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsSUBI: std_logic_vector(CWNBitsID-1 downto 0) := "10101";
    constant CWExBitsSUBI: std_logic_vector(CWNBitsEX-1 downto 0) := "1101000100";
    constant CWMemBitsSUBI: std_logic_vector(CWNbitsMEM-1 downto 0) := "01000";
    constant CWWbBitsSUBI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsORI: std_logic_vector(CWNBitsID-1 downto 0) := "10100";
    constant CWExBitsORI: std_logic_vector(CWNBitsEX-1 downto 0) := "1101011111";
    constant CWMemBitsORI: std_logic_vector(CWNbitsMEM-1 downto 0) := "01000";
    constant CWWbBitsORI: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    constant CWIdBitsADD: std_logic_vector(CWNBitsID-1 downto 0) := "11111";
    constant CWExBitsADD: std_logic_vector(CWNBitsEX-1 downto 0) := "1011000000";
    constant CWMemBitsADD: std_logic_vector(CWNbitsMEM-1 downto 0) := "01000";
    constant CWWbBitsADD: std_logic_vector(CWNbitsWB-1 downto 0) := "11000";

    component BasicDP is
    Generic( NbitMem: integer;
             controlNbit: integer;
             addressNbit: integer );
    port(   Clk :        in std_logic;
            rst :        in std_logic;
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

        --Simple Program with no stalls--

        -- addi r1, r0, 1
        -- addi r2, r0, 2
        -- subi r3, r0, 1
        -- ori  r4, r0, 2
        -- add  r5, r1, r2

        begin

        wait for 1 ns;  

        ControlWord_i<= (others => '0');

        wait for 2 ns;

        IMdata_i <= "00000100000000010000000000000001"; -- instruction bits corresponding to -addi r1, r0, 1- (the opcode assumed for addi is 000001)

       

        	ControlWord_i<= (others => '0');

        --at this point in time, la CU sente il cambiamento alle porte della LUT e di conseguenza riesce a pescare la control word associata. I control bits propagati al dp sono solo quelli correlati alla decode della prima istruzione fetchata 
                --ControlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsADDI ;
        

        wait for 2 ns;
	IMdata_i <= "00000100000000100000000000000010"; -- instruction bits corresponding to -addi r2, r0, 2- 	       


        --fetch of 2nd instruction
        

                ControlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsADDI ;

        --control bits sent to ports of decode unit at this time instant 
                --ControlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsADDI ;
        --controlbits sent to execute unit at this time instannt
                --controlWord_i(controlNbit-1-CWNbitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsADDI;

        -- in questo istante di tempo, la CU forma la controlWord della seconda istruzione del programma. I control bits propagati al datapath in quest istante di tempo saranno:

        

        wait for 2 ns;
               IMdata_i <= "00001100000000110000000000000001"; -- instruction bits corresponding to -subi r3, r0, 1- (opcode assumed for subi is 00011)

        --fetch of 3rd instruction,
	
        
        --control bits sent to ports of decode unit at this time instant 
                ControlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsADDI ;
        --controlbits sent to execute unit at this time instannt
                controlWord_i(controlNbit-1-CWNbitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsADDI;
        
        --controlbits sent to decode unit at this time instant
                --controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsSUBI ;

        --controlbits sent to execute unit at this time instannt
                --controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsADDI;

        --controlbits sent to memory unit at this time instant
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsADDI;

 

        wait for 2 ns;
	IMdata_i <= "00010100000001000000000000000010"; -- instruction bits corresponding to -or r4, r0, 2- 	


        --fetch of 4th instruction
        


        --controlbits sent to decode unit at this time instant
                controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsSUBI ;

        --controlbits sent to execute unit at this time instannt
                controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsADDI;

        --controlbits sent to memory unit at this time instant
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsADDI;

       --controlbits sent to decode unit at this time instant
                --controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsORI ;

        --controlbits sent to execute unit at this time instannt
                --controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsSUBI;

        --controlbits sent to memory unit at this time instant
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsADDI;

        --controlbits sent to writeBack unit at this time instant
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsADDI;

        wait for 2 ns;
		        IMdata_i <= "00000000001000100010100000000000"; --instruction bits corresponding to 5th instruction: -add r5, r1, r2-  (opcode assumed for the add Rtype is 000000 and related FUNC is 00000000000 )

        --fetch of the 5th instruction
        
        --controlbits sent to decode unit at this time instant
                controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsORI ;

        --controlbits sent to execute unit at this time instannt
                controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsSUBI;

        --controlbits sent to memory unit at this time instant
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsADDI;

        --controlbits sent to writeBack unit at this time instant
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsADDI;
        
        
        --controlbits sent to decode unit at this time instant:
                --controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsADD ;
        --controlbits sent to execute unit at this time instannt:
                --controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsORI;
        --controlbits sent to memory unit at this time instant:
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsSUBI;
        --controlbits sent to writeBack unit at this time instant:
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsADDI;

        wait for 2 ns;

        --no more instructions to be fetched

        --controlbits sent to decode unit at this time instant:
                controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= CWIdBitsADD ;
        --controlbits sent to execute unit at this time instannt:
                controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsORI;
        --controlbits sent to memory unit at this time instant:
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsSUBI;
        --controlbits sent to writeBack unit at this time instant:
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsADDI;

        --controlbits sent to decode unit at this time instant:
                --controlWord_i(controlNbit-1 downto controlNbit-1-CWNBitsID) <= (others => '0') ;

        --controlbits sent to execute unit at this time instannt
                --controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsADD;

        --controlbits sent to memory unit at this time instant
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsORI;

        --controlbits sent to writeBack unit at this time instant
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsSUBI;   
		
        wait for 2 ns;

        --no more instructions to be fetched

        --controlbits sent to decode unit at this time instant:
                controlWord_i(controlNbit-1 downto controlNbit-1-CWNBitsID) <= (others => '0') ;

        --controlbits sent to execute unit at this time instannt
                controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= CWExBitsADD;

        --controlbits sent to memory unit at this time instant
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsORI;

        --controlbits sent to writeBack unit at this time instant
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsSUBI;   

        --controlbits sent to execute unit at this time instant
                --controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= (others => '0');

        --controlbits sent to memory unit at this time instant
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsADD;

        --controlbits sent to writeBack unit at this time instant
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsORI;

        wait for 2 ns;

        --no more instructions to be fetched,

        --controlbits sent to execute unit at this time instant
                controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= (others => '0');

        --controlbits sent to memory unit at this time instant
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= CWMemBitsADD;

        --controlbits sent to writeBack unit at this time instant
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsORI;

        --controlbits sent to decode unit at this time instant:
                --controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= (others => '0') ;

        --controlbits sent to execute unit at this time instannt:
                --controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= (others => '0');

        --controlbits sent to memory unit at this time instant:
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= (others => '0');

        --controlbits sent to writeBack unit at this time instant:
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsADD;

        wait for 2 ns;

        --no more instructions to be fetched

        --controlbits sent to decode unit at this time instant:
                controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= (others => '0') ;

        --controlbits sent to execute unit at this time instannt:
                controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= (others => '0');

        --controlbits sent to memory unit at this time instant:
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= (others => '0');

        --controlbits sent to writeBack unit at this time instant:
                controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= CWWBBitsADD;

        --controlbits sent to decode unit at this time instant:
                --controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= (others => '0') ;

        --controlbits sent to decode unit at this time instant:
                --controlWord_i(controlNbit-1 downto controlNbit-CWNBitsID) <= (others => '0') ;

        --controlbits sent to execute unit at this time instannt:
                --controlWord_i(controlNbit-1-CWNBitsID downto controlNbit-CWNBitsID-CWNBitsEX) <= (others => '0');

        --controlbits sent to memory unit at this time instant:
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM) <= (others => '0');

        --controlbits sent to writeBack unit at this time instant:
                --controlWord_i(controlNbit-1-CWNBitsID-CWNBitsEX-CWNBitsMEM downto controlNbit-CWNBitsID-CWNBitsEX-CWNBitsMEM-CWNbitsWB) <= (others => '0');

        wait;

        end process;

end TEST;