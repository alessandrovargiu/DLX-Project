library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity IRAM is
    generic (
        N: integer := 32;-- constants here
        M: integer := 32
    );
    port(
        clk: in std_logic;
        rst: in std_logic;                            -- active low
        I_ADDR : in std_logic_vector(N-1 downto 0);     -- dimensions to be specified     
        I_DATA : out std_logic_vector(M-1 downto 0);
        ready : out std_logic                         -- active high
    );
end entity;

architecture Beh of IRAM is

    constant wdLength : integer := 8;
    type mem is array (0 to M) of std_logic_vector(WDlength-1 downto 0); --penso dovrebbe essere che ha 2^M segnali
    signal memory : mem ;

begin

    process (clk)
        
    begin
        if(rising_edge(clk)) then
            if(unsigned(I_ADDR) < M ) then
                ready <= '1';
                I_DATA <= memory(to_integer(unsigned(I_ADDR))) & memory(to_integer(unsigned(I_ADDR) +1 )) & memory(to_integer(unsigned(I_ADDR) +2)) & memory(to_integer(unsigned(I_ADDR) +3));        
            end if;
        end if;
    end process;

    process (rst)
        
        file fp : text;
        variable file_line : line;
        variable i : integer := 0;
        variable tmp : std_logic_vector(WDlength-1 downto 0);

    begin
        if(Rst = '1') then
            file_open(fp, "StoreAndLoad.mem", READ_MODE); 
            while (not endfile(fp)) loop
            readline(fp, file_line);
                read(file_line, tmp);
                memory(i) <= std_logic_vector(unsigned(tmp));
                i := i + 1;
            end loop;
        file_close(fp);
        end if;
    end process;

end Beh;




