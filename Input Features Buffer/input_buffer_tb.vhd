library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity input_buffer_tb is
end entity input_buffer_tb;

architecture rtl of input_buffer_tb is
    signal CLK, RESET, RX_IN, RX_DONE, READ_ENABLE, WRITE_ENABLE, READ_TICK, WRITE_TICK: std_logic;
    signal MODE: std_logic_vector(1 downto 0);
    signal FIFO_OUT, RX_OUT: signed(7 downto 0);
begin
    input_buffer_obj: entity work.input_buffer
    generic map(
        X=> 2
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        RX_IN=> RX_IN,
        MODE=> MODE,
        D_OUT=> FIFO_OUT,
        READ_ENABLE=> READ_ENABLE,
        WRITE_ENABLE=> WRITE_ENABLE,
        READ_TICK=> READ_TICK,
        WRITE_TICK=> WRITE_TICK,
        RX_OUT=> RX_OUT,
        RX_DONE=> RX_DONE
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
        MODE<= "01";
        RX_IN<= '1';
        wait for 104us;
        RX_IN<= '0';--start bit
        wait for 104us;
        RX_IN<= '0';--LSB
        wait for 104us;
        RX_IN<= '1';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';--MSB
        wait for 104us;
        RX_IN<= '1';--STOP BIT
        wait for 104us;
        RX_IN<= '1';--IDLE
        wait for 104us;
        RX_IN<= '0';--START BIT
        wait for 104us;
        RX_IN<= '0';--LSB
        wait for 104us;
        RX_IN<= '1';
        wait for 104us;
        RX_IN<= '1';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';--MSB
        wait for 104us;
        RX_IN<= '1';--STOP
        wait for 104us;
        RX_IN<= '1';--IDLE
        wait for 104us;
        RX_IN<= '0';--START BIT
        wait for 104us;
        RX_IN<= '1';--LSB
        wait for 104us;
        RX_IN<= '1';
        wait for 104us;
        RX_IN<= '1';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';--MSB
        wait for 104us;
        RX_IN<= '1';--STOP BIT
        wait for 104us;
        RX_IN<= '1';--IDLE
        wait for 104us;
        RX_IN<= '0';--START BIT
        wait for 104us;
        RX_IN<= '1';--LSB
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '1';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';
        wait for 104us;
        RX_IN<= '0';--MSB
        wait for 104us;
        RX_IN<= '1';--STOP BIT
        wait for 104us;
        RX_IN<= '1';--IDLE
        wait ;
    end process;
end architecture rtl;