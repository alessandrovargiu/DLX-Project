-- Im implementing a datapath for the basicDLX structure first

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BasicDP is
    port(   Clk :        in std_logic;
            rst :        in std_logic;
            IMready:     in std_logic;
            DMready:     in std_logic;
            IMdata:      in std_logic_vector(Nbit-1 downto 0);
            controlWord: in srd_logic_vector(controlNbit-1 downto 0);
            IMen:        out std_logic;   --Instruction Mem enable signal
            DMen:        out std_logic;   --Data Mem enable signal
            DM1R0W:      out std_logic;   --when bit is 0--> writing to data mem, when bit is 1--> reading from mem
            IMcurrAddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMdata:      inout std_logic_vector(Nbit-1 downto 0);
    );
end BasicDP;

architecture BasicArch of BasicDP is

---------------------------------------------------------------------------------
--List of the general components 

    --multiplexer 
    component MUX21 is
	    Generic ( MuxNbit:	integer := Nbit);
	    Port (	input1:		In	std_logic_vector(MuxNbit-1 downto 0);
			    input2:		In	std_logic_vector(MuxNbit-1 downto 0);
			    Sel:		In	std_logic;
			    Y:			Out	std_logic_vector(MuxNbit-1 downto 0));
        end component;

    --sign extender
    component sgn_extender is
        port (  se_in    : in std_logic_vector(15 downto 0);
                se_out   : out std_logic_vector(31 downto 0));
        end component ;

    --register 
    component register is
        generic ( RegNbit: integer := Nbit);
        port (  clk:    in std_logic;
                rst:    in std_logic;
                I:      in std_logic_vector(Nbit-1 downto 0);
                Q:      out ts_logic_vector(Nbit-1 downto 0) );
        end component;
        
    --register File (Will be substituted with the windowed one in future)

    component register_file is
        generic( nbit : integer := Nbit;
		         addr_bits : integer := 5);
        port (  CLK: 		IN std_logic;
                RESET: 		IN std_logic;
	 	        ENABLE: 	IN std_logic;
	 	        RD1: 		IN std_logic;
	 	        RD2: 		IN std_logic;
	 	        WR: 		IN std_logic;
	 	        ADD_WR: 	IN std_logic_vector(addr_bits-1 downto 0);
	 	        ADD_RD1: 	IN std_logic_vector(addr_bits-1 downto 0);
	 	        ADD_RD2: 	IN std_logic_vector(addr_bits-1 downto 0);
	 	        DATAIN: 	IN std_logic_vector(nbit-1 downto 0);
     	        OUT1: 		OUT std_logic_vector(nbit-1 downto 0);
	 	        OUT2: 		OUT std_logic_vector(nbit-1 downto 0));
        end component;

    --Comparator4Branch instructions

    component comp4Branch is
        generic(Nbit : integer :=Nbit)
        port(   A:    in  std_logic_vector(Nbit-1 downto 0);
                cond: out std_logic );
        end component;

    --adder component

    component RCA is 
	generic (NbitRca: integer := Nbit);
	--generic (DRCAS : 	Time := 0 ns;
	--         DRCAC : 	Time := 0 ns);
	Port (	A:	In	std_logic_vector(NbitRca-1 downto 0);
			B:	In	std_logic_vector(NbitRca-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(NbitRca-1 downto 0);
			Co:	Out	std_logic);
    end component; 

    --alu

    component ALU is

    generic (N : integer := numBit);
    port (  FUNC: IN TYPE_OP;
            DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
            OUTALU: OUT std_logic_vector(N-1 downto 0) );
    end component;

---------------------------------------------------------------------------------


constant Nbit:          integer := 32;
constant IMAddressNbit:  integer:= 5; --assumendo che IM ha 32 indirizzi


--Fetch Unit related internal signals and instances
signal PCinput: std_logic_vector(addressNbit-1 downto 0);
signal RFinput: std_logic_vector(Nbit-1 downto 0);
signal NPCinput: std_logic_vector(addressNbit-1 downto 0);
signal NPCoutput:std_logic_vector(addressNbit-1 downto 0);
signal co: std_logic;

PC: register --contains current address
generic map(IMaddressNbit)
port map( PCinput, IMcurrAddress) ;

IR: register --contains current instruction
generic map(Nbit);
port map( IMdata, RFinput );

NextAddressGenerator: rca
generic map(IMaddressNbit)
port map (IMcurrAddress, std_logic_vector(4) , '0', NPCinput, co);

NPC: register --stores subsequent instruction address
generic map(IMaddressNbit)
port map(NPCinput, NPCoutput ); 

--Decode Unit related internal signals and instances



end BasicArch;


