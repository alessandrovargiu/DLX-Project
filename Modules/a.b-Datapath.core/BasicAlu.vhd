library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--use IEEE.std_logic_arith.all;
--use WORK.alu_type.all;


entity ALU is

  generic (N : integer );
  port (--FUNC: IN TYPE_OP;
        FUNC: IN std_logic_vector(5 downto 0);
        DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
        OUTALU: OUT std_logic_vector(N-1 downto 0) );
end ALU;

architecture BEHAVIOR of ALU is

begin

P_ALU: process (FUNC, DATA1, DATA2)

  constant SHIFT_bits: integer := integer(ceil(log2(real(N))));    -- log2(N) is the number of bits that contains the range in
  
                                                                -- which DATA1 can be shifted
  begin

    case FUNC is

    when "000000" => --ADD
        OUTALU <= std_logic_vector(unsigned(DATA1)+unsigned(DATA2));
    when "000100"     => --SUB
        OUTALU <= std_logic_vector(unsigned(DATA1)-unsigned(DATA2));
    --when MULT     =>
    --    OUTALU <= std_logic_vector(unsigned(DATA1((N/2)-1 downto 0)) * unsigned(DATA2((N/2)-1 downto 0)));
    when "000010"     => --BITAND  --func bits di bitand probably wrong
        OUTALU <= DATA1 and DATA2; -- bitwise operations
    when "011111"     => --BITOR
        OUTALU <= DATA1 or DATA2;
    --when BITXOR     =>
    --    OUTALU <= DATA1 xor DATA2;
    --when FUNCLSL     =>
    --   OUTALU <= std_logic_vector(shift_left(unsigned(DATA1), to_integer(unsigned(DATA2(SHIFT_bits downto 0))))); -- logical shift left, HELP: use the concatenation operator &
    --when FUNCLSR     =>
    --    OUTALU <= std_logic_vector(shift_right(unsigned(DATA1), to_integer(unsigned(DATA2(SHIFT_bits downto 0))))); -- logical shift right
    --when FUNCRL     =>
    --    OUTALU <= std_logic_vector(rotate_left(unsigned(DATA1), to_integer(unsigned(DATA2(SHIFT_bits downto 0))))); -- rotate left
    --when FUNCRR     =>
    --    OUTALU <= std_logic_vector(rotate_right(unsigned(DATA1), to_integer(unsigned(DATA2(SHIFT_bits downto 0))))); -- toate right
    when others => OUTALU <= (others => '0' )  ;

    end case;
  end process P_ALU;

end BEHAVIOR;



configuration CFG_ALU_BEHAVIORAL of ALU is
  for BEHAVIOR
  end for;
end CFG_ALU_BEHAVIORAL;