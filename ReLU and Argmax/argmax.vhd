library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity argmax is
    generic(
        N: integer:= 8;-- bit width 
        M: integer:= 10 --number of neurons in output layer
    );
    port (
        RESET: in std_logic;
        CLK: in std_logic;
        ACCS: in signed(N* M -1 downto 0);
        ACTIVATIONS: out std_logic_vector(M-1 downto 0)
    );
end entity argmax;

architecture rtl of argmax is
    signal prev: signed(N-1 downto 0):= (others=> '0');
    signal argmax_index, i: unsigned(7 downto 0):= (others=> '0');
begin
    argmax_proc: process (CLK)
    begin
        if rising_edge(CLK) then
            if RESET= '0' then
                if  i < to_unsigned(M,8) then
                    i<= i + 1;
                    if prev < ACCS(to_integer(i+1)*N-1 downto to_integer(i)*N) then
                        prev<= ACCS((TO_INTEGER(i+1))*N-1 downto to_integer(i)*N);
                        argmax_index<= i;
                    end if;
                else
                    i<= (others=> '0');
                end if;
            else
                prev<= (others=> '0');
                argmax_index<= (others=> '0');
                i<= (others=> '0');
            end if;
        end if;
    end process;
    ACTIVATIONS<= std_logic_vector(shift_left(to_signed(1,M), to_integer(argmax_index)));
end architecture rtl;