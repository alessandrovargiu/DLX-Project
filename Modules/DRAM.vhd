library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;


entity DRAM is
    generic (
        -- constants here
    );
    port(
        clk: in std_logic;
        rst: in std_logic;                            -- active low
        RW: in std_logic;                             -- 1 - read, 0 - write
        ADDR: in std_logic_vector(W downto 0);          
        DATA_IN: in std_logic_vector(N downto 0);
        DATA_OUT: in std_logic_vector(N downto 0)
        ready : out std_logic                         -- active high
    );
end entity;

architecture Beh of DRAM is

    type mem is array (0 to M) of std_logic_vector(M downto 0);
    signal memory : mem

begin

    -- does this code allow for simultaneous READ/WRITE ??  to discuss
    process
    begin
        if(rising_edge(clk)) then
            if(rst = '0') then
                memory <= (others => (others => '0'));
            elsif(rst = '1') then
                if(RW = '1') then                       -- READ
                    DATA_OUT <= memory(std_logic_vector(unsigned(ADDR)));
                end if;
                if(RW = '0') then                                    -- WRITE
                    memory(to_integer(unsigned(ADDR))) <= DATA_IN;
                end if;
            end if;
        end if;
    end process;

end Beh;

