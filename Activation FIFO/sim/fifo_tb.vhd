library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_tb is
end entity fifo_tb;

architecture rtl of fifo_tb is
    signal CLK,RESET, EMPTY, FULL, ALMOST_EMPTY, ALMOST_FULL,WRE_TICK, RE_TICK, WRE, RE: std_logic;
    signal D_IN, D_OUT: signed(7 downto 0);
begin
    my_fifo_obj: entity work.fifo
    generic map(
        N=> 8,
        X=> 3,
        J=> 3
    )
    port map(
        CLK=> CLK,
        EMPTY=> EMPTY,
        FULL=> FULL,
        RESET=> RESET,
        ALMOST_EMPTY=> ALMOST_EMPTY,
        ALMOST_FULL=> ALMOST_FULL,
        WRE=> WRE,
        RE=> RE,
        RE_TICK=> RE_TICK,
        WRE_TICK=>WRE_TICK,
        D_IN=> D_IN,
        D_OUT=> D_OUT
    );
    clock_divider: entity work.clock_divider
    generic map(
        WRITE_CYCLES=> 0, --100MHz
        READ_CYCLES=> 1 --50MHz
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        WRE_TICK=> WRE_TICK,
        RE_TICK=> RE_TICK
    );
    --CLOCK : 100 MHz clock
    clkA_proc: process
    begin
        loop 
            CLK<='0';
            wait for 5ns;
            CLK<= '1';
            wait for 5ns;
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
        wait for 10ns;
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
