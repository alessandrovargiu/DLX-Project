library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;


entity DRAM is
    generic (
        W: integer := 32;
        N: integer := 32
    );
    port(
        clk: in std_logic;
        rst: in std_logic;                            -- active low
        EN: in std_logic;
        RW: in std_logic;                             -- 1 - read, 0 - write
        ADDR: in std_logic_vector(W-1 downto 0);          
        DATA_IN: in std_logic_vector(N-1 downto 0);
        DATA_OUT: out std_logic_vector(N-1 downto 0);
        ready : out std_logic                         -- active high
    );
end entity;

architecture Beh of DRAM is

    type mem is array (0 to N) of std_logic_vector(N-1 downto 0);
    signal memory : mem;

begin

    -- does this code allow for simultaneous READ/WRITE ??  to discuss
    process(clk)
    begin
        if(falling_edge(clk)) then --put as falling edge as the RW is set by CU on rising edge of the clock
            if(rst = '1') then
                memory <= (others => (others => '0'));
            elsif(EN = '1') then
                if(RW = '1') then                       -- READ
                    DATA_OUT <= memory(to_integer(unsigned(ADDR)));
                end if;
                if(RW = '0') then                       -- WRITE
                    memory(to_integer(unsigned(ADDR))) <= DATA_IN;
                end if;
            end if;
        end if;
    end process;

end Beh;

