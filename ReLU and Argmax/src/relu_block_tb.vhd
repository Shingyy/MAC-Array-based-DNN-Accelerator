library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity relu_block_tb is
end entity relu_block_tb;

architecture rtl of relu_block_tb is
    signal ACCS, ACTIVATIONS_OUT: signed(31 downto 0);
begin
    relu_block: entity work.relu_block
    port map(
        ACCS=> ACCS,
        ACTIVATIONS_OUT=> ACTIVATIONS_OUT
    );
    stim_proc: process
    begin
        ACCS<= X"23347479";
        wait for 20ns;
        ACCS<= X"f3f4d4c9";
        wait for 20ns;
        ACCS<= X"23a47499";
        wait for 20ns;
        ACCS<= X"e334b489";
        wait ;
    end process;
    
    
end architecture rtl;