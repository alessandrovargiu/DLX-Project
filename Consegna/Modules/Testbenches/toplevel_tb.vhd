LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.INSTR_CODES.ALL;
use work.constants.all;


ENTITY tb is
end tb;

Architecture testbench of tb is

Component CPU IS
    PORT (              
        CLK : IN STD_LOGIC; -- Clock Signal (rising-edge trigger)
        reset : IN STD_LOGIC; -- Reset Signal: Asyncronous Active Low (Negative)
        enable: in std_logic;
		IramDATA: in std_logic_vector(31 downto 0);
		IramADDR: out std_logic_vector (31 downto 0);
		DramDATA_OUT: out std_Logic_vector (31 downto 0);
		DramADDR: out std_logic_vector (31 downto 0);
		DramDATA_IN: in std_logic_vector (31 downto 0);
		cw_mem_bits: out std_logic_vector (1 downto 0) 
    );
END component;

component DRAM is
    --generic (
     --   W: integer := 32;
     --   RAM_DEPTH: integer := 1000
    --);
   port(
        clk: in std_logic;
        rst: in std_logic;
        EN: in std_logic;                            -- active low
        RW: in std_logic;                             -- 1 - read, 0 - write
        ADDR: in std_logic_vector(W-1 downto 0);          
        DATA_IN: in std_logic_vector(N-1 downto 0);
        DATA_OUT: out std_logic_vector(N-1 downto 0);
        ready : out std_logic                         -- active high
    );
end component;

component IRAM is 
    generic (
        RAM_DEPTH: integer := 1200;-- constants here
        I_SIZE: integer := 32
    );
    port(
        rst: in std_logic;                            -- active low
        Addr : in std_logic_vector(N-1 downto 0);     -- dimensions to be specified     
        Dout : out std_logic_vector(M-1 downto 0)
    );
end component;
	signal clk_s, reset_s, enable_s : std_logic;
	signal IramDATA_s, IramADDR_s : std_logic_vector(31 downto 0);
	signal DramDATAOUT_s, DramADDR_s, DramDATAIN_s : std_logic_vector(31 downto 0);
	signal cw_mem_bits_s : std_logic_vector(1 downto 0);
begin
	
	clock: process
	begin
	    clk_s <= '0';
	    wait for 0.5 ns;
	    clk_s <= '1';
	    wait for 0.5 ns;
	end process;
	
	MEM1: IRAM
	--generic map(RAM_DEPTH, I_SIZE)
	port map (
	    rst => reset_s,
	    Addr => IramADDR_s,
	    Dout => IramDATA_s
	);

	MEM2: DRAM
	port map(
	    clk => clk_s,
	    rst => reset_s,
	    en => cw_mem_bits_s(0),
	    RW => cw_mem_bits_s(1),
	    ADDR => DramADDR_s, 
	    DATA_IN => DramDATAOUT_s,
	    DATA_OUT => DramDATAIN_s,
	    ready => open
	);

	UUT: CPU
	port map(
	    clk => clk_s,
	    reset => reset_s,
	    enable => enable_s,
	    IramDATA => IramDATA_s,
	    IramADDR => IramADDR_s,
	    DramDATA_OUT => DramDATAOUT_s,
	    DramADDR => DramADDR_s,
	    DramDATA_IN => DramDATAIN_s,
	    cw_mem_bits => cw_mem_bits_s
	);
	
	test: process
	begin
	   reset_s <= '1';
	   wait for 1.5 ns;
	   reset_s <= '0';
	   enable_s <= '1';
	wait;
	end process;

end architecture;
