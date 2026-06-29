library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dnn_accelerator_tb is
end entity dnn_accelerator_tb;

architecture rtl of dnn_accelerator_tb is
    signal CLK_TX, CLK, RESET, RX_IN, SEND, TX_DONE: std_logic;
    signal MODE: std_logic_vector(1 downto 0);
    signal TX_IN: std_logic_vector(7 downto 0);
    signal ACC_OUT: signed(79 downto 0);
begin
    uart_tx: entity work.top_uart_tx
    port map(
        CLK=> CLK_TX,
        MODE=> MODE,
        SEND=> SEND,
        TX_DATA=> open,
        TX_DONE=> TX_DONE,
        TX_OUT=> RX_IN,
        D_IN=> TX_IN,
        RESET=> RESET,
        BAUD_TICK_OUT=> open
    );
    dnn_accelerator: entity work.dnn_accelerator
    generic map(
        input_vector_length => 64,
        N=> 8,--bit width
        K=> 6,-- 2**K MAC units
        X=> 13,-- Parameter BRAM depth
        N_layers=> 3,-- number of layers
        L1=> 64,-- number of neurons for 1st layer
        L2 => 32, -- number of layers for 2nd layer
        L3 => 10,-- number of neurons for output layer 
        bram_depth=> 13,
        fifo_depth=> 6,
        WRITE_CYCLES=> 8860
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        RX_IN=> RX_IN,
        MODE=> MODE,
        ACC_OUT=> ACC_OUT
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
    clk_TX_proc: process
    begin
        loop
            CLK_TX<= '0';
            wait for 5.8823ns;
            CLK_TX<= '1';
            wait for 5.8823ns;
        end loop;
    end process;
    stim_proc: process
    begin
        RESET<= '1';
        SEND<= '0';
        wait for 23.53ns;
        RESET<= '0';
        MODE<= "01";
        TX_IN<= X"FE";
        SEND<= '1';
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"FA";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"01";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"10";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F9";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"0F";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"FA";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"FD";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F1";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"02";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F1";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"FA";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F9";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F4";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"0A";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"02";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"03";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F7";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"FD";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"08";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"FC";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"10";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"10";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"10";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F2";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F1";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F1";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F4";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F0";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F1";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F2";
        wait for 1250us;
        SEND<= '0';
        wait for 100us;
        SEND<= '1';
        TX_IN<= X"F2";
        wait for 1250us;
        SEND<= '0';
        wait;
    end process;
    
end architecture rtl;