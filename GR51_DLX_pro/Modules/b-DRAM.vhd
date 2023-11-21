library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
--use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity DRAM is
    generic (
        W: integer := 32;
        RAM_DEPTH: integer := 32
    );
    port(
        clk: in std_logic;
        rst: in std_logic;                            -- active low
        EN: in std_logic;
        RW: in std_logic;                             -- 1 - read, 0 - write
        ADDR: in std_logic_vector(W-1 downto 0);          
        DATA_IN: in std_logic_vector(W-1 downto 0);
        DATA_OUT: out std_logic_vector(W-1 downto 0);
        ready : out std_logic                         -- active high
    );
end entity;
architecture Beh of DRAM is

    type mem is array (0 to RAM_DEPTH) of integer;
    signal memory : mem;

begin

    process(clk)
        file mem_fp: text;
        variable file_line : line;
        variable index : integer := 0;
        variable data: std_logic_vector(W-1 downto 0); 
    begin
        if(falling_edge(clk)) then --put as falling edge as the RW is set by CU on rising edge of the clock
            if(rst = '1') then
                file_open(mem_fp, "./000-common.core/001-DMEM_init_file.mem", READ_MODE);    
                while(not endfile(mem_fp)) loop
                    readline(mem_fp, file_line);
                    hread(file_line, data);
                    memory(index) <= conv_integer(unsigned(data));
                    index := index + 1;
                end loop;
                while (index < RAM_DEPTH) loop
                    memory(index) <= 0;
                    index := index + 1;
                end loop;
            elsif(EN = '1') then
                if(RW = '1') then                       -- READ
                    DATA_OUT <= conv_std_logic_vector(memory(conv_integer(unsigned(ADDR))), W);
                end if;
                if(RW = '0') then                       -- WRITE
                    memory(conv_integer(unsigned(ADDR))) <= conv_integer(unsigned(DATA_IN));
                end if;
            end if;
        end if;
    end process;
        
end Beh;
