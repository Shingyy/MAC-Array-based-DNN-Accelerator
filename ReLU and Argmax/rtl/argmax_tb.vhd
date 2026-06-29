library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity argmax_tb is
end entity argmax_tb;

architecture rtl of argmax_tb is
    signal RESET,CLK: std_logic;
    signal ACCUMULATIONS: signed(79 downto 0);
    signal ACTIVATIONS: std_logic_vector(9 downto 0);
begin
    argmax_obj: entity work.argmax
    generic map(
        M=> 10
    )
    port map(
        RESET=> RESET,
        CLK=> CLK,
        ACCS=> ACCUMULATIONS,
        ACTIVATIONS=> ACTIVATIONS
    );
    clk_proc: process
    begin
        loop
            CLK<= '0';
            wait for 5ns;
            CLK<= '1';
            wait for 5ns;
        end loop;
    end process;
    stim_proc: process
    begin
        RESET<= '1';
        wait for 20ns;
        RESET<= '0';
        ACCUMULATIONS<= X"bbe70223ece8e2ddb9f1";
        wait ;
    end process;
    
end architecture rtl;