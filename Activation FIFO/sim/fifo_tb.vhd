library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_tb is
end entity fifo_tb;

architecture rtl of fifo_tb is
    signal CLK_A, CLK_B,RESET, EMPTY, FULL, ALMOST_EMPTY, ALMOST_FULL, WRE, RE: std_logic;
    signal D_IN, D_OUT: signed(7 downto 0);
begin
    my_fifo_obj: entity work.fifo
    port map(
        CLK_A=> CLK_A,
        CLK_B=> CLK_B,
        EMPTY=> EMPTY,
        FULL=> FULL,
        RESET=> RESET,
        ALMOST_EMPTY=> ALMOST_EMPTY,
        ALMOST_FULL=> ALMOST_FULL,
        WRE=> WRE,
        RE=> RE,
        D_IN=> D_IN,
        D_OUT=> D_OUT
    );
    --CLOCK A: 100 MHz clock
    clkA_proc: process
    begin
        loop 
            CLK_A<='0';
            wait for 5ns;
            CLK_A<= '1';
            wait for 5ns;
        end loop;
    end process;
    --CLOCK B: 50 MHz clock
    clkB_proc: process
    begin
        loop 
            CLK_B<='0';
            wait for 10ns;
            CLK_B<= '1';
            wait for 10ns;
        end loop;
    end process;
    stim_proc: process
    begin
        WRE<= '0';
        RE<= '0';
        RESET<= '1';
        D_IN<= X"00";
        wait for 20ns;
        WRE<= '1';
        RE<= '0';
        RESET<= '0';
        D_IN<= X"01";
        wait for 10ns;
        WRE<= '1';
        RE<= '0';
        D_IN<= X"20";
        wait for 10ns;
        WRE<= '1';
        RE<= '0';
        D_IN<= X"0a";
        wait for 10ns;
        WRE<= '1';
        RE<= '0';
        D_IN<= X"10";
        wait for 10ns;
        WRE<= '1';
        RE<= '0';
        D_IN<= X"32";
        wait for 10ns;
        WRE<= '1';
        RE<= '0';
        D_IN<= X"50";
        wait for 10ns;
        WRE<= '1';
        RE<= '0';
        D_IN<= X"3f";
        wait for 10ns;
        WRE<= '1';
        RE<= '0';
        D_IN<= X"4c";
        wait for 10ns;
        WRE<= '0';
        RE<= '1';
        wait;
    end process;
end architecture rtl;