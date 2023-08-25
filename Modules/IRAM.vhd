library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;


entity IRAM is
    generic (
        -- constants here
    );
    port(
        clk: in std_logic;
        rst: in std_logic;                            -- active low
        I_ADDR : in std_logic_vector(N downto 0);     -- dimensions to be specified     
        I_DATA : out std_logic_vector(M downto 0);
        ready : out std_logic                         -- active high
    );
end entity;

architecture Beh of IRAM is

    type mem is array (0 to M) of std_logic_vector(M downto 0);
    signal memory : mem

begin

    process
    begin
        if(rising_edge(clk)) then
            if(Rst = '0') then
                memory <= (others => (others => '0'));
                ready <= '0';
            else
                ready <= '1';
                I_DATA <= memory(to_integer(unsigned(I_ADDR)));        
            end if;
        end if;
    end process;

    load_mem : process                     -- load instructions from file to mem array
        file fp : text;
        variable line : line;
        variable i : integer;
        variable tmp : std_logic_vector(M downto 0);
    begin
        file_open(fp, "file.mem", READ_MODE);
        while (not endfile(fp)) loop
            readline(fp, line);
            read(line, tmp)
            memory(i) <= std_logic_vector(unsigned(tmp));
            i := i + 1;
        end loop;
        wait;
    end process;

end Beh;




