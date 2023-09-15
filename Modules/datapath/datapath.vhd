
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BasicDP is
    Generic( NbitMem: integer;
             controlNbit: integer;
             addressNbit: integer );
    port(   Clk:        in std_logic;
            rst:        in std_logic;
            
            fromHU:      in std_logic;
            enable:      in std_logic;
            IMdata:      in std_logic_vector(NbitMem-1 downto 0);  --is the instruction entering the dp and is input to the IR pipeline register in IF/ID bank
            controlWord: in std_logic_vector(controlNbit-1 downto 0);
            
            IMAddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMaddress:   out std_logic_vector(addressNbit-1 downto 0);
            DMdata:      inout std_logic_vector(NbitMem-1 downto 0)
    );
end BasicDP;

architecture BasicArch of BasicDP is

constant Nbit:          integer   := 32; -- l istruzione e' composta da 32 bit  TDO:capire perche mi da errore se lo chiamo Nbit
constant IMAddressNbit:  integer  := 5; --    assumendo che IM ha 32 indirizzi
constant RFaddrNbit:     integer  := 5; --   assumendo che anche il RF ha 32 indirizzi per 32 regs
constant CWNbit:         integer  := 25; --  number of bits of the control word
constant OpcodeNbit:      integer := 6; --  Number of bits of the opcode
constant FuncNbit:        integer := 11; -- number of bits of the func field in R type instructions
constant NbitImmidiateI:    integer := 16; 
constant NbitImmidiateJ:    integer := 26; 

---------------------------------------------------Fetch Unit related internal signals------------------------------------------------------

signal PCinput, PCout: std_logic_vector(Nbit-1 downto 0); 
signal NPCinputIF:     std_logic_vector(Nbit-1 downto 0); --signal in input to IF/ID pipe reg
signal IRoutputID:     std_logic_vector(Nbit-1 downto 0);        --signal of output to the IR reg in IF/ID register bank
signal NPCoutputID:    std_logic_vector(Nbit-1 downto 0); --signal of out from the IF/ID pipe reg
signal co: std_logic;

signal adder1Out: std_logic_vector(Nbit-1 downto 0);
signal pcPlus4orJ: std_logic_vector(Nbit-1 downto 0);

---------------------------------------------------Decode Unit related internal signals---------------------------------------------------------------

--signal RFWritePortAddress:    std_logic_vector(RFaddrNbit-1 downto 0);
signal RFDataIn:              std_logic_vector(Nbit-1 downto 0); --which will be the data output from the writeback phase
signal RFOutRegAIn:           std_logic_vector(Nbit-1 downto 0);  --signal rapresenting the wire acting as output to second read port of RF and as input to regA pipeReg
signal RFOutRegBIn:           std_logic_vector(Nbit-1 downto 0);  --signal rapresenting the wire acting as output to second read port of RF and as input to regB pipeReg
signal RegAoutEX:               std_logic_vector(Nbit-1 downto 0); --signal which is the wire coming out of the Register A pipeline register and will be used in the EX phase
signal RegBoutEX:             std_logic_vector(Nbit-1 downto 0); --signal which is the wire coming out of the Register B pipeline register and will be used in the EX phase

signal NPCoutputEX:           std_logic_vector(Nbit-1 downto 0); --NPC signal which is output from the NPC register of the ID/EX register bank
signal IRoutputEX:            std_logic_vector(Nbit-1 downto 0); --IR signal whic is output from the IR register of the ID/EX register bank
signal rt_dest:                std_logic_vector(RFaddrNbit-1 downto 0); --signal used as output to the rt register to be then used during execution phase
signal rd_dest:                std_logic_vector(RFaddrNbit-1 downto 0); --signal used as output of the rd pipe register. it will be used during execution phase
signal NPCoutputMEM:           std_logic_vector(Nbit-1 downto 0); ----NPC signal which is output from the NPC register of the EX/MEM register bank

signal unsignedImmfrom16:     std_logic_vector(Nbit-1 downto 0);
signal signedImmfrom16:       std_logic_vector(Nbit-1 downto 0);
signal unsignedImmfrom26:     std_logic_vector(Nbit-1 downto 0);
signal signedImmfrom26:       std_logic_vector(Nbit-1 downto 0);

signal extendedImmediateIn:   std_logic_vector(Nbit-1 downto 0); --is the extended immidiate that will be stored in the pipe reg part of ID/EX bank
signal extendedImmediateOut:  std_logic_vector(Nbit-1 downto 0); --is the output signal that will allow to propagate the imm to the execution phase

signal PCVal: std_logic_vector(Nbit-1 downto 0);

------------------------------------------------------Execution Unit internal signals ----------------------------------------------------

signal condIn, notcondIn:       std_logic; 
signal condOut, notcondOut:     std_logic; --these are propagated to the mem phase and will be used as input of the muxes that will determine if to jump or not 
signal operandA, operandB:      std_logic_vector(Nbit-1 downto 0); --operandA is the finilized operand to be fed to ALU. it is the output of top mux. similar for operandB
signal ALUOutEX:                std_logic_vector(Nbit-1 downto 0); --output of ALU and input of pipeReg ex/mem
signal ALURegOutMEM:            std_logic_vector(Nbit-1 downto 0); --output of the ALUREG pipe register. signal is used in mem phase
signal IRoutputMEM:             std_logic_vector(Nbit-1 downto 0); --output of the IR pipeReg in the EX/MEM bank. signal is propagated to mem phase.
signal regBoutMEM:              std_logic_vector(Nbit-1 downto 0); --signal which will be output of the EX/MEM stage and will serve as input to the Data memory if we need to do a store in mem
signal RFWritePortAddressEX:    std_logic_vector(RFaddrNbit-1 downto 0); --input to EX/MEM stage, propagates to Mem stage.
signal NPCoutputWB:             std_logic_vector(Nbit-1 downto 0);

-----------------------------------------------------Memory Unit internal signals------------------------------------------------------------------------

signal branchStatus: std_logic; --used to select if the PC stores NPC or an adress from jump/branch instruction. 
signal LMDRegOutWB: std_logic_vector(Nbit-1 downto 0); --this signal is output of LMD pipe register part of the MEM/WB pipe. it could be used during WB
signal IRoutputWB: std_logic_vector(Nbit-1 downto 0); --signal which is output of the MEM/WB pipe
signal ALUregOutWB: std_logic_vector(Nbit-1 downto 0); --sginal which is output of the MEM/WB pipe and will be used during WB stage.
signal RFWritePortAddressMEM: std_logic_vector(RFaddrNbit-1 downto 0); --signal which is output of the EX/MEM pipe and input to the MEM/WB pipe

signal muxTemporary1, muxTemporary2: std_logic;

-----------------------------------------------------Write Back Internal Signals-------------------------------------------------------------------------------
signal RFWritePortAddressWB: std_logic_vector(RFaddrNbit-1 downto 0); --is signal used in wb. it comes as output from the mem/wb phase
signal finalAddressWB:       std_logic_vector(RFaddrNbit-1 downto 0); --could be 31 in case of jal, or destination address specified in instruction bits of rtype/itype isntr.
signal fromMemOrFromAlu:     std_logic_vector(Nbit-1 downto 0);

-------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------List of the general components--------------------------------------------------------

    --multiplexers
    component oneBitMux21 is
        Port(in1: in std_logic;
             in2: in std_logic;
             sel: in std_logic;
             oneBitOut: out std_logic);
    end component;

    component Mux21 is
	    Generic ( MuxNbit:	integer := Nbit);
	    Port (	input1:		In	std_logic_vector(MuxNbit-1 downto 0);
			    input2:		In	std_logic_vector(MuxNbit-1 downto 0);
			    Sel:		In	std_logic;
			    Y:			Out	std_logic_vector(MuxNbit-1 downto 0));
        end component;

    component MUX41 is
	    Generic ( MuxNbit: integer );
	    Port (	input1:		In	std_logic_vector(MuxNbit-1 downto 0); --unsigned input of 16 bits
			    input2:		In	std_logic_vector(MuxNbit-1 downto 0); --signed input of 16 bits
                input3:     IN  std_logic_vector(MuxNbit-1 downto 0); --unsigned input of 26 bits
                input4:     in  std_logic_vector(MuxNbit-1 downto 0); --signed input of 26 bits
			    Sel:		In	std_logic_vector(1 downto 0); --these selections will be coming from the CU that will tell
			    Y:			Out	std_logic_vector(MuxNbit-1 downto 0));
        end component;

    --sign extender
    component sgn_extender is
        generic ( NbitIn: integer;  --is either 16 (for immediate instruction ) or 26 for jump instruction type
                  NbitImm: integer ); --usually 32
        port ( signedOrUnsigned:  in std_logic; 
               se_in:             in std_logic_vector(NbitIn-1 downto 0);
               se_out:            out std_logic_vector(NbitImm-1 downto 0) );
    end component ;

    --FlipFlop
    component FlipFlop is
        port (  clk:    in std_logic;
            rst:    in std_logic;
            en:     in std_logic;
            I:      in std_logic;
            Q:      out std_logic);
    end component;

    --register for pipeling
    component myregister is
        generic ( RegNbit: integer );
        port (  clk:    in std_logic;
                rst:    in std_logic;
                en:     in std_logic;
                I:      in std_logic_vector(RegNbit-1 downto 0);
                Q:      out std_logic_vector(RegNbit-1 downto 0) );
        end component;
        
    --register File (Will be substituted with the windowed one in future)
    component register_file is
        generic( nbit : integer ;
		         addr_bits : integer );
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
        generic(Nbit : integer );
        port(   A:    in  std_logic_vector(Nbit-1 downto 0);
                cond: out std_logic );
        end component;

    --adder component

    component RCA is 
	    generic (NbitRca: integer );
	--generic (DRCAS : 	Time := 0 ns;
	--         DRCAC : 	Time := 0 ns);
	    Port (	
            A:	In	std_logic_vector(NbitRca-1 downto 0);
			B:	In	std_logic_vector(NbitRca-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(NbitRca-1 downto 0);
			Co:	Out	std_logic);
    end component; 

    --alu

    component ProAlu is
    generic( Nbit: integer := 32;
             OperationSelNbit: integer := 6);
    port( OperandA:     in std_logic_vector(Nbit-1 downto 0);
          OperandB:     in std_logic_vector(Nbit-1 downto 0);
          OperationSel: in std_logic_vector(6-1 downto 0);
          ALUOut:       out std_logic_vector(Nbit-1 downto 0)
          );
end component;

---------------------------------------------------------------------------------
--Brief description of my interpretetion of control bits

--the official control signal once the Proalu has been finilized: 

--|RF1|RF2|EN1|UorS|JorIImm|S1|S2|rdChoice|EN2|ALU1|ALU2|ALU3|ALU4|ALU5|ALU6|Bop|Eq|WM|EN3|RM|WF1|EN4|S4|S5|jalEn|
--|24-|23-|22-|21--|---20--|19|18|---17---|16-|--15|-14-|-13-|-12-|-11-|-10-|9--|-8|-7|--6|-5|--4|-3-|2-|1-|--0--|
--|---decode---------------|----exec----------------------------------------|----mem---------|-----wb------------|


--RF1 enables the first read port of RF1
--RF2 enables the second read port of RF2
--EN1 enables ID/EX pipes regs and RF
--UorS is able to tell DP if the immediate to extend is to be interpreted as unsigned or signed
--JorIMM is able to tell DP is the immediate to extend has originally 16 bits or 26


--S1 selects if to store in pipe "regA" the NPC or the value coming from register at address from first read port of RF. 1 if regA, 0 if npc
--S2 selects if to store in pipe "regB"  the value coming from register at address from first read port of RF or the IMM
--rdChoice selects to store in pipe reg (belonging to ex/mem pipe regs family) the rd or the rt field depending on the type of instruction
--EN2 enables EX/MEM pipe regs
--ALU1 
--ALU2
--ALU3
--ALU4  bits that serve to select the operation which ALU needs to output
--ALU5
--ALU6

--WM enables the write operation of the memory
--EN3 enables the MEM/WB pipe regs
--RM enables the read operation of memory (this control bit will be as input to the memory I believe)
--Bop serves to let dp know if the instruction to analyze is of branch type. if it is, we will pass to the next 2 to 1 mux the cond and cond complement
--Eq bit serves to distinguish the BEQNZ and BEQ instruction. or to distingush if the instruction was of jump type or anyother type

--WF1 enables the write port of the RF
--EN4 enables the rf for the writing (nn sono sicuro se ce bisogno)
--S4 chooses if we need to write back data from the LMD pipe register (if fot instance we have a load inst) or if we need to write back data from the output of the ALU
--S5 chooses if we need to write back data from the VAL or if we need to write NPC in case we have a jaò
--jalEN bit serves to understand if we write the address of PC+4 into the 31st register of the RF (this in the case of jal), or if we simply write to the address of the RF specified by any non-jal instruction

begin 

--------------------------------------------------Fetch Unit related component instances-------------------------------------------------------------


--contains current address
PC: myregister 
generic map(Nbit)
port map( clk, rst, enable, PCinput, PCout ) ; --storage of current address

NextAddressGenerator: rca
generic map(Nbit)
port map ( PCout, x"00000004" , '0', Adder1Out, co );  --generates NPC

--mux choosing if giving as output PC+4 or address of jump
NextPCchoice0: Mux21 
generic map(Nbit)      
port map( Adder1Out, ALUOutEX, branchStatus, pcPlus4orJ ); 

--mux choosing if PC stays the same in case of hazard, or if provifing (PC+4/jumpAddres)
NextPCchoice1: Mux21
generic map(Nbit)
port map( pcPlus4orJ, PCout, fromHU, PCinput );  

---registers part of the IF/ID pipe 

--contains current instruction
IR_0: myregister 
generic map(Nbit)
port map( clk, rst, enable, IMdata,  IRoutputID );  --called IRoutputID because the output of the content of the IR stage is going to the Instruction decode stage

--stores subsequent instruction address
NPC_0: myregister 
generic map(Nbit)
port map(clk, rst, enable, PCout, NPCoutputID ); 

IMAddress <= PCinput ;

---------------------------------------------------Decode Unit related component instances--------------------------------------------------------

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


BasicRF: register_file
generic map(Nbit, RFaddrNbit)   
port map (  CLK => clk, 
            RESET => rst,
            --ENABLE => enableRF, --enables the RF as a whole 
            ENABLE => '1',
            --RD1 => controlWord(CWNbit-1), --enable readPort1 of RF
            RD1 => '1',
            --RD2 => controlWord(CwNbit-2), --enable Read port2 of RF
            RD2 => '1',
            WR => controlWord(CWNbit-21), --enables write port
            ADD_WR => finalAddressWB, 
            ADD_RD1 => IRoutputID(Nbit-1-OpcodeNbit downto Nbit-OpcodeNbit-RFaddrNbit), --address of source register 1
            ADD_RD2 => IRoutputID(Nbit-1-OpcodeNbit-RFaddrNbit downto Nbit-OpcodeNbit-RFaddrNbit-RFaddrNbit), --address of source register 2
            DATAIN => RFDataIn,
            OUT1 => RFOutRegAIN,
            OUT2 => RFOutRegBIN ); 

unsignedImmValueFrom16: sgn_extender
generic map(NbitIn => 16, NbitImm => 32)
port map( signedOrUnsigned => '0', se_in => IRoutputID(NbitImmidiateI-1 downto 0), se_out => unsignedImmfrom16); 

signedImmValueFrom16: sgn_extender
generic map(NbitIn => 16, NbitImm => 32)
port map( signedOrUnsigned => '1', se_in => IRoutputID(NbitImmidiateI-1 downto 0), se_out => signedImmfrom16); 

unsignedImmValueFrom26: sgn_extender
generic map(NbitIn => 26, NbitImm => 32)
port map( signedOrUnsigned => '0', se_in => IRoutputID(NbitImmidiateJ-1 downto 0), se_out => unsignedImmfrom26); 

signedImmValueFrom26: sgn_extender
generic map(NbitIn => 26, NbitImm => 32)
port map( signedOrUnsigned => '1', se_in => IRoutputID(NbitImmidiateJ-1 downto 0), se_out => signedImmfrom26); 

ImmidiateChoice: MUX41
generic map (Nbit)  --usually inputs of 32 bits
port map (input1 => unsignedImmfrom16, --00
          input2 => signedImmfrom16,  --01 
          input3 => unsignedImmfrom26, --10
          input4 => signedImmfrom26, --11
          Sel    => controlWord(CWNbit-4 downto CWNbit-5), --chooses on these 2 criterias: 1. if the value was to be interpreted as unsigned or signed, 2. if the value was converted from 16->32 or 26->32 
          Y      => extendedImmediateIn );

-- registers part of the ID/EX pipe stage 

--still storing the NPC with respect to the processed instr.
NPC_1: myregister
generic map(Nbit)
--port map(clk => clk, rst => rst, en => controlWord(CWNbit-3), I => NPCoutputID, Q => NPCoutputEX);
port map(clk => clk, rst => rst, en => '1', I => NPCoutputID, Q => NPCoutputEX);

--forse e' da togliere la propagazione del istruzione ad ogni pipe register?
IR_1: myregister  
generic map(Nbit)
--port map(clk => clk, rst => rst, en => controlWord(CWNbit-3), I => IRoutputID, Q => IRoutputEX );
port map(clk => clk, rst => rst, en => '1', I => IRoutputID, Q => IRoutputEX );

RegA: myregister 
generic map(Nbit)
--port map(clk => clk, rst => rst, en => controlWord(CWNbit-3), I => RFOutRegAIn, Q => RegAoutEX );
port map(clk => clk, rst => rst, en => '1', I => RFOutRegAIn, Q => RegAoutEX );

RegB: myregister
generic map(Nbit)
--port map(clk => clk, rst => rst, en => controlWord(CWNbit-3), I => RFOutRegBIn, Q => RegBoutEX ); 
port map(clk => clk, rst => rst, en => '1', I => RFOutRegBIn, Q => RegBoutEX ); 

ImmReg: myregister
generic map(Nbit)
--port map(clk => clk, rst => rst, en => controlWord(CWNbit-3), I => extendedImmediateIn, Q => extendedImmediateOut ); 
port map(clk => clk, rst => rst, en => '1', I => extendedImmediateIn, Q => extendedImmediateOut ); 

--rt is the convention for expressing the destination address of an register Rtype instruction
rt: myregister 
generic map(RegNbit => RFaddrNbit)
--port map( clk => clk, rst => rst, en => controlWord(CWNbit-3), I => IRoutputID(Nbit-1-OpcodeNbit-RFaddrNbit-RFaddrNbit downto FuncNbit), Q => rt_dest );
port map( clk => clk, rst => rst, en => '1', I => IRoutputID(Nbit-1-OpcodeNbit-RFaddrNbit-RFaddrNbit downto FuncNbit), Q => rt_dest );

--rd is the convention for expressing the destination address of an immidiate Itype instruction
rd: myregister 
generic map(RFaddrNbit)
--port map(clk => clk, rst => rst, en => controlWord(CWNbit-3), I => IRoutputID(Nbit-1-OpcodeNbit-RFaddrNbit downto Nbit-OpcodeNbit-RFaddrNbit-RFaddrNbit), Q => rd_dest );
port map(clk => clk, rst => rst, en => '1', I => IRoutputID(Nbit-1-OpcodeNbit-RFaddrNbit downto Nbit-OpcodeNbit-RFaddrNbit-RFaddrNbit), Q => rd_dest );

------------------------------------------------------Execution Unit related component instances------------------------------------------------------------

zeroQcomp: comp4Branch
generic map(Nbit)
port map( RegAoutEX, condIn );  --if value stored in regAoutEx is 0, cond is 1

notcondin <= not condIn; -- value stored in regAoutEx is 0, notcond is set to 0

ChooseFirstOperand: Mux21
generic map (Nbit)
port map ( NPCoutputEX, regAoutEX, controlWord(CWNbit-6), operandA) ; --0 prendo NPC , 1 prendo A. 


ChooseSecondOperand: Mux21
generic map(Nbit)
port map( RegBoutEX, extendedImmediateOut , controlWord(CWNbit-7), operandB ) ; -- 0 prendo B, 1 prendo imm

ProALuinstance: ProAlu 
generic map(Nbit)
port map (operandA, operandB, controlWord(CWNbit-10 downto CWNbit-15),  ALUOutEX); -- 6 bit di control per l alu

--this below serves to understand which bit range location we should look at in the instruction to understand the address of where to write our result
--for instance: if we have an I type instruction, the address of the register in which we store the result is located in the bit range [11,15] 
--              if we have an R type instruction, the address of the register in which we store the result is located in the bit range [16,20]

--0 if sel is 0, we select the destination from the immediate
--1 if del is 1 we selcr destination from the rtype

rdestinationChoice: Mux21
generic map(RFaddrNbit)
port map( rd_dest, rt_dest, ControlWord(CWNbit-8), RFWritePortAddressEX );

Mux1forJump: oneBitMux21
port map('1', condIn, controlWord(CWNbit-16), muxTemporary1 ); --if this selection bit is 0, we are not analyzing a branch instruction

Mux2forJump: oneBitMux21
port map('0', notcondin, controlWord(CWNbit-16), muxTemporary2 ); --if this selection bit is 0, we ae not analyzing a branch instruction

FinalMux4Jump: oneBitMux21
port map(  muxTemporary2, muxTemporary1, ControlWord(CWNbit-17), branchStatus );--if this selection bit is 0, it means that we are not suppose to jump (for instance if the analyzed instruction is an addi) or the analyzed instruction is a BNEZ


--Execution Unit Pipe registers

IR_2: myregister
generic map(Nbit)
--port map(clk, rst, controlWord(CWNbit-9), IRoutputEX, IRoutputMEM );
port map(clk, rst, '1', IRoutputEX, IRoutputMEM );

NPC_2: myregister
generic map(Nbit)
--port map(clk => clk, rst => rst, en => controlWord(CWNbit-9), I => NPCoutputEX, Q => NPCoutputMEM);
port map(clk => clk, rst => rst, en => '1', I => NPCoutputEX, Q => NPCoutputMEM);

--pipe flip flop storing if regA is equal to 0
--BranchCondition: FlipFlop 
--port map(clk, rst, controlWord(CWNbit-9), condIn, condOut) ;
--port map(clk, rst, '1', condIn, condOut) ;

--pipe flip flop storing if regA is not equal to 0
--BranchNotCondtion: FlipFlop
--port map(clk, rst, controlWord(CWNbit-9), notcondIn, notcondOut) ;
--port map(clk, rst, '1', notcondIn, notcondOut) ;

--pipe register saving the computed result of the ALU
ALUOUT_reg_0: myregister 
generic map(Nbit)
--port map ( clk, rst, controlWord(CWNbit-9), ALUOutEX, ALURegOutMEM ); --(ALURegOutEX is signal going as input to the ALUREG pipe register in the EX/MEM bank)
port map ( clk, rst, '1', ALUOutEX, ALURegOutMEM );

ForMemStore: myregister
generic map(Nbit)
--port map(clk, rst, controlWord(CWNbit-9), regBoutEX, regBoutMEM);
port map(clk, rst, '1', regBoutEX, regBoutMEM);

destinationAddressReg1: myregister
generic map(RFaddrNbit)
--port map(clk, rst, controlWord(CWNbit-9), RFWritePortAddressEX, RFWritePortAddressMEM);
port map(clk, rst, '1', RFWritePortAddressEX, RFWritePortAddressMEM);

-----------------------------------------------------Memory Unit component instances----------------------------------------------------------------------------

DMaddress <= ALURegOutMEM;
DMdata <= RegBoutMEM;

--Memory Unit Pipe registers

IR_3: myregister
generic map(Nbit)
--port map(clk, rst, controlWord(CWNbit-17), IRoutputMEM, IRoutputWB);
port map(clk, rst, '1', IRoutputMEM, IRoutputWB);

NPC_3: myregister
generic map(Nbit)
--port map(clk => clk, rst => rst, en => controlWord(CWNbit-17), I => NPCoutputMEM, Q => NPCoutputWB);
port map(clk => clk, rst => rst, en => '1', I => NPCoutputMEM, Q => NPCoutputWB);

LMDReg: myregister
generic map(Nbit)
--port map( clk, rst, controlWord(CWNbit-17), DMdata, LMDRegOutWB);
port map( clk, rst, '1', DMdata, LMDRegOutWB);

ALUout_reg_1: myregister
generic map(Nbit)
--port map( clk, rst, controlWord(CWNbit-17), ALUregOutMEM, ALUregOutWB);
port map( clk, rst, '1', ALUregOutMEM, ALUregOutWB);

destinationAddressReg2: myregister
generic map(RFaddrNbit)
--port map(clk, rst, controlWord(CWNbit-17), RFWritePortAddressMEM, RFWritePortAddressWB);
port map(clk, rst, '1', RFWritePortAddressMEM, RFWritePortAddressWB);

-----------------------------------------------------Write Back component instances---------------------------------------------------------------------------

--choosing if writing back a value that was obtained from dataMem (in case of load instruction) or a value obtained from the result from the ALU.
RFinChoice: Mux21
generic map(Nbit)
port map( ALURegOutWB, LMDRegOutWB, controlWord(CWNbit-23), fromMemOrFromAlu );

-- costruire un mux per ricollegare questo punto: val se sel = 0, se no se sel e 1 PC+4 (che serve per mettere il PC+4 nel R31 se e' una jal) 
StoresNPCorValue: Mux21
generic map(Nbit)
port map( fromMemOrFromAlu , NPCoutputWB, controlWord(CWNbit-24), RFDataIn);

--chooses if we need to write in the 31st location of the RF (in case we are processing  a jal instruction) or if simiply writing to a the address speficied in rdestination field bits of the instruction
JALChoice: Mux21  
generic map( RFaddrNbit )
port map (  RFWritePortAddressWB, "11111", controlWord(CWNbit-25), finalAddressWB ); 

 --enableRF <= (controlWord(CWNbit-22)) or (controlWord(CWNbit-3));

end BasicArch;