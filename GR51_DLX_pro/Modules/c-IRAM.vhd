library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;


-- Instruction memory for DLX
-- Memory filled by a process which reads from a file

entity IRAM is
  generic (
    RAM_DEPTH : integer := 48;
    I_SIZE : integer := 32);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );

end IRAM;

architecture IRam_Bhe of IRAM is

  type RAMtype is array (0 to RAM_DEPTH - 1) of integer;

  signal IRAM_mem : RAMtype;

begin  
process(Addr)
begin
  if (unsigned(Addr) < RAM_DEPTH) then
    Dout <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr))),I_SIZE);
  end if;
end process;
  FILL_MEM_P: process (Rst)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
  begin  
    if (Rst = '1') then
      file_open(mem_fp,"./000-common.core/002-IMEM_init_file.mem",READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        IRAM_mem(index) <= conv_integer(unsigned(tmp_data_u));       
        index := index + 1;
      end loop;
      while (index < RAM_DEPTH) loop
        IRAM_mem(index) <= 0;
        index := index + 1;
      end loop;
    end if;
  end process FILL_MEM_P;

end IRam_Bhe;