library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity relu_block is
    generic(
        N: integer:= 8;
        K: integer:= 2
    );
    port (
        ACCS:in signed(2**K*N-1 downto 0);
        ACTIVATIONS_OUT: out signed(2**K*N-1 downto 0)
    );
end entity relu_block;

architecture rtl of relu_block is
    
begin
    relu_units: for i in 0 to 2**K-1 generate
        relu_unit: entity work.relu
        generic map(
            N=> N
        )
        port map(
            ACC=> ACCS((i+1)*N-1 downto i*N),
            ACTIVATION=> ACTIVATIONS_OUT((i+1)*N-1 downto i*N)
        );
    end generate;
end architecture rtl;