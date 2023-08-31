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

    --multiplexers

    component oneBitMux21 is
        Port(in1: in std_logic;
             in2: in std_logic;
             sel: in std_logic;
             oneBitOut: out std_logic);
    end component;

    component MUX21 is
	    Generic ( MuxNbit:	integer := Nbit);
	    Port (	input1:		In	std_logic_vector(MuxNbit-1 downto 0);
			    input2:		In	std_logic_vector(MuxNbit-1 downto 0);
			    Sel:		In	std_logic;
			    Y:			Out	std_logic_vector(MuxNbit-1 downto 0));
        end component;

    component MUX41 is
	    Generic ( MuxNbit );
	    Port (	input1:		In	std_logic_vector(ImmField1Nbit-1 downto 0); --unsigned input of 16 bits
			    input2:		In	std_logic_vector(ImmField1Nbit-1 downto 0); --signed input of 16 bits
                input3:     IN  std_logic_vector(ImmField2Nbit-1 downto 0); --unsigned input of 26 bits
                input4:     in  std_logic_vector(ImmField2Nbit-1 downto 0); --signed input of 26 bits
			    Sel:		In	std_logic_vector(2-1 downto 0); --these selections will be coming from the CU that will tell
			    Y:			Out	std_logic_vector(MuxNbit-1 downto 0));
        end component;

    component sgn_extender is
        generic ( NbitIn: integer;  --is either 16 (for immediate instruction ) or 26 for jump instruction type
                  NbitImm: integer ); --usually 32
        port ( signedOrUnsigned:  in std_logic; 
               se_in:             in std_logic_vector(NbitIn-1 downto 0);
               se_out:            out std_logic_vector(NbitImm-1 downto 0) );
    end component ;

    --sign extender
    component sgn_extender is
        
        port (  signedOrUnsigned: in std_logic; 
                se_in           : in std_logic_vector(15 downto 0);
                se_out          : out std_logic_vector(31 downto 0));
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

    component FlipFlop is
        port (  clk:    in std_logic;
            rst:    in std_logic;
            en:     in std_logic;
            I:      in std_logic;
            Q:      out std_logic);
    end component;


---------------------------------------------------------------------------------

--the assumed control signal is the following : 
--|EN1|RF1|RF2|UorS|JorIImm|EN2|S1|S2|rdChoice|ALU1|ALU2|ALU3|ALU4|EN3|RM|WM|Bop|Eq|EN4|S3|WF1|jalEn|
--|21-|20-|19-|-18-|---17--|16-|15|14|---13---|-12-|-11-|-10-|--9-|-8-|7-|-6|-5-|4-|-3-|2-|-1-|--0--|
--|---decode---------------|----exec------------------------------|----mem---------|-----wb---------|

--Brief description of my interpretetion of control bits

--EN1 enables ID/EX pipes regs and RF
--RF1 enables the first read port of RF1
--RF2 enables the second read port of RF2
--UorS is able to tell DP if the immediate to extend is to be interpreted as unsigned or signed
--JorIMM is able to tell DP is the immediate to extend has originally 16 bits or 26

--EN2 enables EX/MEM pipe regs
--S1 selects if to store in pipe "regA" the NPC or the value coming from register at address from first read port of RF
--S2 selects if to store in pipe "regB"  the value coming from register at address from first read port of RF or the IMM
--rdChoice selects to store in pipe reg (belonging to ex/mem pipe regs family) the rd or the rt field depending on the type of instruction
--ALU1 
--ALU2
--ALU3
--ALU4  bits that serve to select the operation which ALU needs to output

--EN3 enables the MEM/WB pipe regs
--RM enables the read operation of memory (this control bit will be as input to the memory I believe)
--WM enables the write operation of the memory
--Bop serves to let dp know if the instruction to analyze is of branch type. if it is, we will pass to the next 2 to 1 mux the cond and cond complement
--Eq bit serves to distinguish the BEQNZ and BEQ instruction. or to distingush if the instruction was of jump type or anyother type

--EN4 enables the rf for the writing (nn sono sicuro se ce bisogno)
--S3 chooses if we need to write back data from the LMD pipe register (if fot instance we have a load inst) or if we need to write back data from the output of the ALU
--WF1 enables the write port of the RF
--jalEN bit serves to understand if we write the address of PC+4 into the 31st register of the RF (this in the case of jal), or if we simply write to the address of the RF specified by any non-jal instruction



constant Nbit:          integer   := 32; -- l istruzione e' composta da 32 bit
constant IMAddressNbit:  integer  := 5; --    assumendo che IM ha 32 indirizzi
constant RFaddrNbit:     integer  := 5; --   assumendo che anche il RF ha 32 indirizzi per 32 regs
constant CWNbit:         integer  := 14; --  number of bits of the control word
constant OpcodeNbit:      integer := 6; --  Number of bits of the opcode
constant FuncNbit:        integer := 11; -- number of bits of the func field in R type instructions
constant NbitImmidiateI    integer := 16; 
constant NbitImmidiateJ    integer := 26; 

---------------------------------------------------Fetch Unit related internal signals and instances-----------------------------------------------
signal PCinput: std_logic_vector(addressNbit-1 downto 0);
signal IRoutputIF: std_logic_vector(Nbit-1 downto 0);
signal NPCinputIF: std_logic_vector(addressNbit-1 downto 0);
signal NPCoutputIF:std_logic_vector(addressNbit-1 downto 0);
signal co: std_logic;

PC: register --contains current address
generic map(IMaddressNbit)
port map( clk, rst, enable, PCinput, IMAddress) ;

NextAddressGenerator: rca
generic map(IMaddressNbit)
port map (IMAddress, "1001" , '0', NPCinputIF, co);

NextPCchoice: Mux21
generic map(Nbit)
port map( NPCoutputIF, ALURegOut, branchStatus, PCinput );
---registers part of the IF/ID pipe stage

IR_0: register --contains current instruction
generic map(Nbit);
port map( clk, rst, enable, IMdata,  IRoutputIF );

NPC_0: register --stores subsequent instruction address
generic map(IMaddressNbit)
port map(clk, rst, enable, NPCinputIF, NPCoutputIF ); 



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

signal unsignedImmfrom16:     std_logic_vector(Nbit-1 downto 0);
signal signedImmfrom16:       std_logic_vector(Nbit-1 downto 0);
signal unsignedImmfrom26:     std_logic_vector(Nbit-1 downto 0);
signal signedImmfrom26:       std_logic_vector(Nbit-1 downto 0);


BasicRF: register_file
generic map(Nbit, RFaddrNbit)   
port map (  CLK => clk, 
            RESET => rst,
            ENABLE => controlWord(CWNbit-1), --enables the RF as a whole 
            RD1 => controlWord(CWNbit-2), --enable readPort1 of RF
            RD2 => controlWord(CwNbit-3), --enable Read port 2 of RF
            WR => ControlWord(CWNbit-21); --enables write port
            ADD_WR => finalAddressWB, 
            ADD_RD1 => IRoutputIF(Nbit-1-OpcodeNbit downto Nbit-1-OpcodeNbit-RFaddrNbit), --address of source register 1
            ADD_RD2 => IRoutputIF(Nbit-1-OpcodeNbit-RFNbit downto Nbit-1-OpcodeNbit-RFaddrNbit-RFaddrNbit), --address of source register 2
            DATAIN => RFDataIn,
            OUT1 => RFOutRegAIN,
            OUT2 => RFOutRegBIN
            ); 

unsignedImmValueFrom16: sgn_extender
generic map(NbitIn => 16, NbitImm => 32)
port map( signedOrUnsigned => '0', se_in => IRoutputIF(NbitImmidiateI-1 downto 0), se_out => unsignedImmfrom16); 

signedImmValueFrom16: sgn_extender
generic map(NbitIn => 16, NbitImm => 32)
port map( signedOrUnsigned => '1', se_in => IRoutputIF(NbitImmidiateI-1 downto 0), se_out => signedImmfrom16); 

unsignedImmValueFrom26: sgn_extender
generic map(NbitIn => 26, NbitImm => 32)
port map( signedOrUnsigned => '0', se_in => IRoutputIF(NbitImmidiateJ-1 downto 0), se_out => unsignedImmfrom26); 

signedImmValueFrom26: sgn_extender
generic map(NbitIn => 26, NbitImm => 32)
port map( signedOrUnsigned => '1', se_in => IRoutputIF(NbitImmidiateJ-1 downto 0), se_out => signedImmfrom26); 

ImmidiateChoice: MUX41
generic map (Nbit)  --usually inputs of 32 bits
port map (input1 => unsignedImmfrom16,
          input2 => signedImmfrom16,
          input3 => unsignedImmfrom26,
          input4 => signedImmfrom26,
          Sel    => controlWord(CWNbit-4 downto CWNbit-5), --chooses on these 2 criterias: 1. if the value was to be interpreted as unsigned or signed, 2. if the value was converted from 16->32 or 26->32 
          Y      => extendedImmediateIn );

-- registers part of the ID/EX pipe stage 
NPC_1: register
generic map(Nbit)
port map(clk => clk, rst => rst, en => controlWord(CWNbit-1), I => NPCoutputIF, Q => NPCoutputID);

IR_1: register  --forse e' da togliere la propagazione del istruzione ad ogni pipe register?
generic map(Nbit)
port map(clk => clk, rst => rst, en => controlWord(CWNbit-1), I => IRoutputIF, Q => IRoutputID );

tempRegA: register --contains current instruction
generic map(Nbit)
port map(clk => clk, rst => rst, en => controlWord(CWNbit-1), I => RFOutRegAIN, Q => RegAout );

tempRegB: register
generic map(Nbit)
port map(clk => clk, rst => rst, en => controlWord(CWNbit-1), I => RFOutRegBIN, Q => RegBoutID ); 

ImmReg: register
generic map(Nbit)
port map(clk => clk, rst => rst, en => controlWord(CWNbit-1), I => extendedImmediateIn, Q => extendedImmediateOut ); 

rt: register --rt is the convention for expressing the destination address of an register Rtype instruction
generic map(RFaddrNbit)
port map( clk => clk, rst => rst, en => controlWord(CWNbit-1), I => IRoutputIF(Nbit-1-OpcodeNbit-RFaddrNbit-RFaddrNbit downto FuncNbit), Q => rt_dest );

rd: register --rt is the convention for expressing the destination address of an immidiate Itype instruction
generic map(RFaddrNbit)
port map(clk => clk, rst => rst, en => controlWord(CWNbit-1), I => IRoutputIF(Nbit-1-OpcodeNbit-RFaddrNbit downto Nbit-1-OpcodeNbit-RFaddrNbit-RFaddrNbit), Q => rd_dest );

------------------------------------------------------Execution Unit internal signals and component instances----------------------------------------------------

signal condIn, notcondIn:       std_logic;
signal condOut, notcondOut:     std_logic;
signal operandA, operandB:      std_logic_vector(Nbit-1 downto 0);
signal ALUOut:                  std_logic_vector(Nbit-1 downto 0);
signal ALURegOutEX:             std_logic_vector(Nbit-1 downto 0);
signal IRoutputEX:              std_logic_vector(Nbit-1 downto 0);
signal regBoutEX:               std_logic_vector(Nbit-1 downto 0);
signal RFWritePortAddressEX:    std_logic_vector(addressNbit-1 downto 0);

notcondin <= not condIn;

zeroQcomp: comp4Branch
generic map(Nbit)
port map( regAout, branchStatus);

ChooseFirstOperand: Mux21
generic map (Nbit)
port map ( NPCoutputID, regAout, controlWord(CWNbit-7), operandA) ;

ChooseSecondOperand: Mux21
generic map(Nbit)
port map( regBout, extendedImmediateOut , controlWord(CWNbit-8), operandB ) ;

BasicALUinstance: ALU 
generic map(Nbit)
port map ( controlWord(CWNbit-10 downto CWNbit-13), operandA, operandB, ALUOut); --al momento deciso che ci stanno 4 bit per la control word dell alu

--this below serves to understand which bit range location we should look at in the instruction to understand the address of where to write our result
--for instance: if we have an I type instruction, the address of the register in which we store the result is located in the bit range [11,15] 
--              if we have an R type instruction, the address of the register in which we store the result is located in the bit range [16,20]
RFWriteAddressChoice: Mux21
generic map(RFaddrNbit)
port map(   rt,
            rd,
            ControlWord(CWNbit-9), 
            RFWritePortAddressEX );

--Execution Unit Pipe registers

BranchCondition: FlipFlip 
port map(clk, rst, controlWord(CWNbit-6), condIn, condOut) ;

BranchNotCondtion: FlipFlop
port map(clk, rst, controlWord(CWNbit-6), notcondIn, notcondOut) ;

ALUOUT_reg_0: register 
generic map(Nbit)
port map ( clk, rst, controlWord(CWNbit-6), ALUOut, ALURegOutEX );

IR_2: register
generic map(Nbit)
port map(clk, rst, controlWord(CWNbit-6), IRoutputID, IRoutputEX );

ForMemStore: register
generic map(Nbit)
port map(clk, rst, controlWord(CWNbit-6), regBoutID, regBoutEX);

destinationAddressReg: register
generic map(addressNbit)
port map(clk, rst, controlWord(CWNbit-6), RFWritePortAddressEX, RFWritePortAddressMEM);



-----------------------------------------------------Memory Unit internal signals and component instances---------------------------------------------------

signal branchStatus: std_logic;
signal LMDRegOut: std_logic_vector(Nbit-1 downto 0);
signal IRoutputMEM: std_logic_vector(Nbit-1 downto 0);
signal ALUregOutMEM: std_logic_vector(Nbit-1 downto 0);
signal RFWritePortAddressMEM: std_logic_vector(addressNbit-1 downto 0);


Mux1: oneBitMux21
port map('1', condOut, controlWord(CWNbit-17), mux3input1 ); --if this selection bit is 0, we are not analyzing a branch instruction

Mux2: oneBitMux21
port map('0', notcondOut, controlWord(CWNbit-17), mux3input2 ); --if this selection bit is 0, we ae not analyzing a branch instruction

Mux2: oneBitMux21
port map( mux3input1, mux3input2, ControlWord(CWNbit-18), branchStatus );--if this selection bit is 0, it means that we are not suppose to jump (for instance if the analyzed instruction is an addi) or the analyzed instruction is a BNEZ

NextPCchoice: Mux21
generic map(Nbit)
port map( NPCoutput, ALURegOutEX, branchStatus, PCinput);

DMaddress <= ALURegOutEX;
DMdata <= RegBout;

--Memory Unit Pipe registers

IR_3: register
generic map(Nbit)
port map(clk, rst, controlWord(CWNbit-14), IRoutputEX, IRoutputMEM);

LMDReg: register
generic map(Nbit)
port map( clk, rst, controlWord(CWNbit-14), DMdata, LMDRegOut);

ALUout_reg_1: register
generic map(Nbit)
port map( clk, rst, controlWord(CWNbit-14), ALUregOutEX);

destinationAddressReg: register
generic map(addressNbit)
port map(clk, rst, controlWord(CWNbit-14), RFWritePortAddressMEM, RFWritePortAddressWB);

-----------------------------------------------------Write Back Internal Signals and component instances-----------------------------------------------------
signal RFWritePortAddressWB: std_logic_vector(addressNbit-1 downto 0);
signal finalAddressWB:       std_logic_vector(addressNbit-1 downto 0);

--choosing if writing back a value that was obtained from dataMem (in case of load instruction) or a value obtained from the result from the ALU.
RFinChoice: Mux21
generic map(Nbit)
port map( LMDRegOut, ALURegOut, controlWord(CWNbit-20), RFDataIn);

--chooses if we need to write in the 31st location of the RF (in case we are processing  a jal instruction) or if simiply writing to a the address speficied in rdestination field bits of the instruction
JALChoice: Mux21  
generic map(addressNbit)
port map ( std_logic_vector(31), RFWritePortAddressWB, controlWord(CWNbit-22), finalAddressWB );--(the offset determining the control bit needs to be fixed)


end BasicArch;