library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity batch_argmax is
    generic(
        N: integer:= 8;
        M: integer:= 4
    );
    port (
        CLK: in std_logic;
        RESET: in std_logic;
        ACCS: in signed(N*M-1 downto 0);
        ARGMAX_OUT: out std_logic_vector(M-1 downto 0)
    );
end entity batch_argmax;

architecture rtl of batch_argmax is
    signal MAX_OUT,max_out_reg: signed(M*N -1 downto 0);
    signal ARG_INDEX : unsigned(M-2 downto 0);
    signal argmax: std_logic_vector(M-1 downto 0);
begin
    MAX_OUT(N-1 downto 0) <= ACCS(N-1 downto 0);
    comparators: for i in 0 to M-2 generate
    comparator: entity work.comparator
    generic map(
        N=> N
    )
        port map(
            A=> max_out_reg((i+1)*N-1 downto i*N),
            B=> ACCS((i+2)*N-1 downto (i+1)*N),
            MAX=> MAX_OUT((i+2)*N-1 downto (i+1)*N),
            INDEX=> ARG_INDEX(i downto i)
        );
    myregister: entity work.n_bit_register
    generic map(
        N=> N
    )
    port map(
        CLK=> CLK,
        R=> RESET,
        D=> MAX_OUT((i+1)*N-1 downto i*N),
        Q=> max_out_reg((i+1)*N-1 downto i*N)
    );
    end generate;

    process (ARG_INDEX) is
    begin
        for j in 0 to M-2 loop
            if ARG_INDEX(j)= '1' then
                argmax<= std_logic_vector(shift_left(to_unsigned(1,M),j+1));
            end if;
        end loop;
    end process;
    ARGMAX_OUT<= std_logic_vector(to_unsigned(1,M)) when ARG_INDEX= to_unsigned(0,M-1)or RESET= '1' or ACCS= to_signed(0,N*M) else argmax;             
end architecture rtl;