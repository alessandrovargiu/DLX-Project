package CONSTANTS is
   constant IVDELAY : time := 0.1 ns;
   constant NDDELAY : time := 0.2 ns;
   constant NDDELAYRISE : time := 0.6 ns;
   constant NDDELAYFALL : time := 0.4 ns;
   constant NRDELAY : time := 0.2 ns;
   constant DRCAS : time := 1 ns;
   constant DRCAC : time := 2 ns;
   constant NBIT : integer := 32;	
   constant TP_MUX : time := 0.5 ns;
   constant N: integer := 32;-- constants here
   constant M: integer := 32;
   constant W: integer := 32;
   constant Nbit:          integer   := 32; -- l istruzione e' composta da 32 bit  TDO:capire perche mi da errore se lo chiamo Nbit
   constant IMAddressNbit:  integer  := 5; --    assumendo che IM ha 32 indirizzi
   constant RFaddrNbit:     integer  := 5; --   assumendo che anche il RF ha 32 indirizzi per 32 regs
   constant CWNbit:         integer  := 25; --  number of bits of the control word
   constant OpcodeNbit:      integer := 6; --  Number of bits of the opcode
   constant FuncNbit:        integer := 11; -- number of bits of the func field in R type instructions
   constant NbitImmidiateI:    integer := 16; 
   constant NbitImmidiateJ:    integer := 26;  	
end CONSTANTS;
