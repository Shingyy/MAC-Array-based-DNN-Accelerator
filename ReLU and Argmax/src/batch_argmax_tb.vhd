library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity batch_argmax_tb is
end entity batch_argmax_tb;

architecture rtl of batch_argmax_tb is
    signal ACCS: signed(31 downto 0);
    signal ARGMAX_OUT: std_logic_vector(3 downto 0);
    signal RESET, CLK: std_logic;
begin
    batch_argmax: entity work.batch_argmax
    generic map(
        M=> 4
    )
    port map(
        ACCS=> ACCS,
        RESET=> RESET,
        CLK=> CLK,
        ARGMAX_OUT=> ARGMAX_OUT
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
        ACCS<= X"f124d770";
        wait for 100ns;
        ACCS<= X"f12433e5";
        wait for 100ns;
        ACCS<= X"f124cee5";
        wait for 100ns;
        ACCS<= X"00bacee5";
        wait for 100ns;
        RESET<= '1';
        wait ;
    end process;
    
end architecture rtl;