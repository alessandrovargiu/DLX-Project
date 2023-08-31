-- Im implementing a datapath for the basicDLX structure first

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BasicDP is
    Generic( Nbit: integer;
             controlNbit: integer;
             addressNbit: integer );
    port(   Clk :        in std_logic;
            rst :        in std_logic;
            
            enable:      in std_logic;
            IMdata:      in std_logic_vector(Nbit-1 downto 0);
            controlWord: in srd_logic_vector(controlNbit-1 downto 0);
            
            IMAddress:   out std_logic_vector(addressNbit-1 downto 0);
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
                en:     in std_logic;
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
	 	        OUT2: 		OUT std_logic_vector(nbit-1 downto 0) );
        end component;

    --Comparator4Branch instructions

    component comp4Branch is
        generic(Nbit : integer :=Nbit);
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
        port (--FUNC: IN TYPE_OP;
            FUNC: IN std_logic_vector(1 downto 0);
            DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
            OUTALU: OUT std_logic_vector(N-1 downto 0) );
    end component;

    component Cond_FF is

    generic ( RegNbit: integer := Nbit);
    port (  clk:    in std_logic;
            rst:    in std_logic;
            en:     in std_logic;
            I:      in std_logic;
            Q:      out std_logic);
    end component;

---------------------------------------------------------------------------------

--the assumed control signal is the following: 
--|EN0|EN1|RF1|RF2|EN2|S1|S2|ALU1|ALU2|EN3|RM|WM|S3|EN4|WF1|WF2|
--

constant Nbit:          integer   := 32; -- l istruzione e' composta da 32 bit
constant IMAddressNbit:  integer  := 5; --    assumendo che IM ha 32 indirizzi
constant RFaddrNbit:     integer  := 5; --   assumendo che anche il RF ha 32 indirizzi per 32 regs
constant CWNbit:         integer  := 14; --  number of bits of the control word
constant OpcodeNbit:      integer := 6; --  Number of bits of the opcode
constant FuncNbit:        integer := 11; -- number of bits of the func field in R type instructions
constant NbitImmidiate    integer := 16; 

---------------------------------------------------Fetch Unit related internal signals and instances-----------------------------------------------
signal PCinput: std_logic_vector(addressNbit-1 downto 0);
signal IR_OUT: std_logic_vector(Nbit-1 downto 0);
signal PC_OUT: std_logic_vector(addressNbit-1 downto 0);
signal NPC_IN: std_logic_vector(addressNbit-1 downto 0);
signal NPC_OUT:std_logic_vector(addressNbit-1 downto 0);
signal co: std_logic;

    PC: register --contains current address
    generic map(IMaddressNbit)
    port map(clk, rst, enable, PC_IN, PC_OUT) ;

    PC_Adder: rca
    generic map(IMaddressNbit)
    port map (PC_OUT, std_logic_vector(4) , '0', NPC_IN, co);

    IR_0: register      --contains current instruction
    generic map(Nbit);
    port map( clk, rst, enable, IMdata, IR_OUT);

    NPC_0: register     --stores subsequent instruction address (PC)
    generic map(IMaddressNbit)
    port map(clk, rst, enable, NPC_IN, NPC_OUT); 

    NextPCchoice: Mux21
    generic map(Nbit)
    port map( NPC_OUT, ALURegOut, branchStatus, PC_IN );

---------------------------------------------------Decode Unit related internal signals and instances----------------------------------------------


--------------------------------------------------------------
--I TYPE instruction structure
--|------------|----------|----------|--------------------------------|
--|OPCODE------|ReadPort1-|WritePort-|ImmidiateValue------------------|
--|31--------26|25------21|20------16|15-----------------------------0|
--|-----OP-----|---rs1----|----rt---|---------------Imm---------------|

--R TYPE instruction structure
--|------------|----------|----------|--------------------------------|
--|OPCODE------|ReadPort1-|ReadPort2-|WritePort|Func------------------|
--|31--------26|25------21|20------16|15-----11|10-------------------0|
--|-----OP-----|---rs1----|----rs2---|---rd----|---------Func---------|

--------------------------------------------------------------

--signal RFWritePortAddress:    std_logic_vector(RFaddrNbit-1 downto 0);
signal RFDataIn:              std_logic_vector(Nbit-1 downto 0); --which will be the data output from the writeback phase
signal RFOutRegAIN:           std_logic_vector(Nbit-1 downto 0);
signal RFOutRegBIN:           std_logic_vector(Nbit-1 downto 0);
signal RegAout:               std_logic_vector(Nbit-1 downto 0);
signal RegBoutID:             std_logic_vector(Nbit-1 downto 0);
signal extendedImmediateIn:   std_logic_vector(Nbit-1 downto 0);
signal extendedImmediateOut:  std_logic_vector(Nbit-1 downto 0);
signal NPCoutputID:           std_logic_vector(Nbit-1 downto 0);
signal IRoutputID:            std_logic_vector(Nbit-1 downto 0);
signal rt_dest                std_logic_vector(addressNbit downto 0);
signal rd_dest                std_logic_vector(addressNbit downto 0);

--this serves to understand which bit range location we should look at in the instruction to understand the address of where to write our result
--for instance: if we have an I type instruction, the address of the register in which we store the result is located in the bit range [11,15] 
--              if we have an R type instruction, the address of the register in which we store the result is located in the bit range [16,20]


BasicRF: register_file
generic map(Nbit, RFaddrNbit)   
port map (  clk, 
            rst,
            controlWord(CWNbit-1-1), --enables the RF as a whole
            controlWord(CWNbit-1-2), --enable readPort1 of RF
            controlWord(CwNbit-1-3), --enable Read port 2 of RF
            ControlWord(1); 
            finalAddressWB, 
            IRoutputIF(Nbit-1-OpcodeNbit downto Nbit-1-OpcodeNbit-RFaddrNbit), --address of source register 1
            IRoutputIF(Nbit-1-OpcodeNbit-RFNbit downto Nbit-1-OpcodeNbit-RFaddrNbit-RFaddrNbit), --address of source register 2
            RFDataIn,
            RFOutRegAIN,
            RFOutRegBIN
            ); 

ImmExtender: sgn_extender
port map( IRoutputIF(NbitImmidiate-1 downto 0), ExtendedImmediateIn); 


-- registers part of the ID/EX pipe stage 
NPC_1: register
generic map(Nbit)
port map(clk, rst, controlWord(CWNbit-1-1), NPCoutputIF, NPCoutputID);

IR_1: register
generic map(Nbit)
port map(clk, rst, controlWord(CWNbit-1-1), IRoutputIF, IRoutputID );

tempRegA: register --contains current instruction
generic map(Nbit)
port map( clk, rst, controlWord(CWNbit-1-1), RFOutRegAIN,  RegAout );

tempRegB: register
generic map(Nbit)
port map( clk, rst, controlWord(CWNbit-1-1), RFOutRegBIN,  RegBoutID ); 

ImmReg: register
generic map(Nbit)
port map( clk, rst, controlWord(CWNbit-1-1), extendedImmediateIn,  extendedImmediateOut ); 

rt: register --rt is the convention for expressing the destination address of an register Rtype instruction
generic map(RFaddrNbit)
port map( clk, rst, controlWord(CWNbit-1-1), IRoutputIF(Nbit-1-OpcodeNbit-RFaddrNbit-RFaddrNbit downto FuncNbit), rt_dest );

rd: register --rt is the convention for expressing the destination address of an immidiate Itype instruction
generic map(RFaddrNbit)
port map( clk, rst, controlWord(CWNbit-1-1), IRoutputIF(Nbit-1-OpcodeNbit-RFaddrNbit downto Nbit-1-OpcodeNbit-RFaddrNbit-RFaddrNbit), rd_dest );

------------------------------------------------------Execution Unit internal signals and component instances----------------------------------------------------


signal branchStatus:       std_logic;
signal operandA, operandB: std_logic_vector(Nbit-1 downto 0);
signal ALUOut:             std_logic_vector(Nbit-1 downto 0);
signal ALURegOutEX:          std_logic_vector(Nbit-1 downto 0);
signal IRoutputEX:         std_logic_vector(Nbit-1 downto 0);
signal regBoutEX:          std_logic_vector(Nbit-1 downto 0);
signal RFWritePortAddressEX   std_logic_vector(addressNbit-1 downto 0);

zeroQcomp: comp4Branch
generic map(Nbit)
port map( regAout, branchStatus);

ChooseFirstOperand: Mux21
generic map (Nbit)
port map ( NPCoutputID, regAout, controlWord(CWNbit-1-5), operandA) ;

ChooseSecondOperand: Mux21
generic map(Nbit)
port map( regBout, extendedImmediateOut , controlWord(CWNbit-1-6), operandB ) ;

BasicALUinstance: ALU 
generic map(Nbit)
port map ( controlWord(CWNbit-1-7 downto CWNbit-1-8), operandA, operandB, ALUOut); 

RFWriteAddressChoice: Mux21
generic map(RFaddrNbit)
port map(   rt,
            rd,
            ControlWord(CWNbit-1-offset), --todo: determine offset
            RFWritePortAddressEX);

--Execution Unit Pipe registers

BranchCondition: Cond_FF --e' un flip flop dato che ha 1 bit come input e 1 bit come output
port map(clk, rst, controlWord(CWNbit-4), branchStatus, branchStatus) ;

ALUOUT_reg_0: register 
generic map(Nbit)
port map ( clk, rst, controlWord(CWNbit-1-4), ALUOut, ALURegOutEX );

IR_2: register
generic map(Nbit)
port map(clk, rst, controlWord(CWNbit-1-4), IRoutputID, IRoutputEX );

ForMemStore: register
generic map(Nbit)
port map(clk, rst, controlWord(CWNbit-1-4), regBoutID, regBoutEX);

destinationAddressReg: register
generic map(addressNbit)
port map(clk, rst, controlWord(CWNbit-1-4), RFWritePortAddressEX, RFWritePortAddressMEM);



-----------------------------------------------------Memory Unit internal signals and component instances---------------------------------------------------

signal LMDRegOut: std_logic_vector(Nbit-1 downto 0);
signal IRoutputMEM: std_logic_vector(Nbit-1 downto 0);
signal ALUregOutMEM: std_logic_vector(Nbit-1 downto 0);
signal RFWritePortAddressMEM: std_logic_vector(addressNbit-1 downto 0);

NextPCchoice: Mux21
generic map(Nbit)
port map( NPCoutput, ALURegOutEX, branchStatus, PCinput);

DMaddress <= ALURegOutEX;
DMdata <= RegBout;

--Memory Unit Pipe registers

IR_3: register
generic map(Nbit)
port map(clk, rst, controlWord(CWNbit-1-9), IRoutputEX, IRoutputMEM);

LMDReg: register
generic map(Nbit)
port map( clk, rst, controlWord(CWNbit-1-9), DMdata, LMDRegOut);

ALUout_reg_1: register
generic map(Nbit)
port map( clk, rst, controlWord(CWNbit-1-9), ALUregOutEX);

destinationAddressReg: register
generic map(addressNbit)
port map(clk, rst, controlWord(CWNbit-1-4), RFWritePortAddressMEM, RFWritePortAddressWB);

-----------------------------------------------------Write Back Internal Signals and component instances-----------------------------------------------------
signal RFWritePortAddressWB: std_logic_vector(addressNbit-1 downto 0);
signal finalAddressWB:       std_logic_vector(addressNbit-1 downto 0);

RFinChoice: Mux21
generic map(Nbit)
port map( LMDRegOut, ALURegOut, controlWord(CWNbit-1-10), RFDataIn);

--chooses if we need to write in the 31st location of the RF (in case we are processing  a jal instruction) or if simiply writing to a generic address in th RF

JALChoice: Mux21  
generic map(addressNbit)
port map ( std_logic_vector(31), RFWritePortAddressWB, controlWord(CWNbit-1-11), finalAddressWB );--(the offset determining the control bit needs to be fixed)


end BasicArch;