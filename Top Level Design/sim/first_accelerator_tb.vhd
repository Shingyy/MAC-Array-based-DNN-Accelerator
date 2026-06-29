library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity first_accelerator_tb is
end entity first_accelerator_tb;

architecture rtl of first_accelerator_tb is
    signal CLK, RESET, COMPUTE_EN, CLR_ACC, OL, IL, TX_DONE,WRE, SEND,RE, ACTIVATION_FIFO_RESET,PARAM_BUFFER_RESET, EMPTY ,FULL, RX_DONE, RX_IN: std_logic;
    signal PARAM_SRC : std_logic_vector(12 downto 0);
    signal PARAM_DEST, ACTIVATION_SRC: std_logic_vector(5 downto 0);
    signal PARAMS_OUT: std_logic_vector(511 downto 0);
    signal D_OUT: std_logic_vector(7 downto 0); 
    signal MAC_ARRAY_OUT_REQUANT: signed(511 downto 0);
    signal ACTVNS_OUT: signed(511 downto 0);
    signal MAC_ARRAY_OUT: signed(1023 downto 0);
    signal ACTIVATION_BUFFER_OUT: std_logic_vector(7 downto 0);
    signal ACTIVATION_OUT: signed(7 downto 0);
    signal DATABUS_OUT, FIFO_OUT: signed(7 downto 0);
    signal DATABUSES: signed(15 downto 0);
    signal MODE: std_logic_vector(1 downto 0);
    signal ARGMAX_OUT: std_logic_vector(9 downto 0);
    signal ACCUMMULATIONS_OUT: signed(1023 downto 0);
    signal TX_IN: std_logic_vector(7 downto 0);
begin
    DATABUSES(15 downto 8)<= FIFO_OUT;
    DATABUSES(7 downto 0)<= ACTIVATION_OUT;
    uart_tx: entity work.top_uart_tx
    port map(
        CLK=> CLK,
        MODE=> MODE,
        SEND=> SEND,
        TX_DATA=> open,
        TX_DONE=> TX_DONE,
        TX_OUT=> RX_IN,
        D_IN=> TX_IN,
        RESET=> RESET,
        BAUD_TICK_OUT=> open
    );
    relu_block: entity work.relu_block
    generic map(
        N=> 8,
        K=> 6
    )
    port map(
        ACCS=> ACCUMMULATIONS_OUT(511 downto 0),
        ACTIVATIONS_OUT=> ACTVNS_OUT
    );
    argmax: entity work.argmax
    generic map(
        N=> 8,
        M=> 10-- number of neurons in the output layer
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        ACCS=> ACCUMMULATIONS_OUT(591 downto 512),
        ACTIVATIONS=> ARGMAX_OUT
    );
    accum_demux: entity work.accum_demux
    generic map(
        N=> 8,
        K=> 6
    )
    port map(
        ACCUMMULATIONS_IN=> MAC_ARRAY_OUT_REQUANT,
        ACCUMMULATIONS_OUT=> ACCUMMULATIONS_OUT,
        SEL=> OL
    );
    parameter_bram: entity work.parameter_bram
    generic map(
        N=> 8,
        K=> 13
    )
    port map(
        CLK=> CLK,
        CLR=> '0',
        PARAM_ADDR=> PARAM_SRC,
        PARAM_OUT=> D_OUT
    );
    activation_fifo: entity work.activation_fifo
    generic map(
        N=> 8,
        X=> 6
    )
    port map(
        CLK=> CLK,
        RESET=> ACTIVATION_FIFO_RESET,
        RE=> RE,
        WRE=> WRE,
        EMPTY=> open, 
        FULL=> open,
        RE_TICK=> COMPUTE_EN,
        ACTIVATION_IN=> signed(ACTIVATION_BUFFER_OUT),
        ACTIVATION_OUT=> ACTIVATION_OUT
    );
    activation_buffer: entity work.activation_buffer
    generic map(
        N=> 8,
        K=> 6
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        ADDR=> ACTIVATION_SRC,
        ACTIVATIONS=> std_logic_vector(ACTVNS_OUT),
        ACTIVATION_OUT=> ACTIVATION_BUFFER_OUT
    );
    param_buffer: entity work.param_buffer
    generic map(
        N=> 8,
        K=> 6
    )
    port map(
        PARAM_IN=> D_OUT,
        CLK=> CLK,
        RESET=> PARAM_BUFFER_RESET,
        ADDR=> PARAM_DEST,
        PARAMS_OUT=> PARAMS_OUT
    );
    mac_control_unit: entity work.mac_control_unit
    generic map(
        Input_vector_length=> 64,-- X_IN should be a 8-vector
        N=> 8,--bit width
        K=> 6,-- 2**K MAC units
        X=> 13,-- Parameter BRAM Address bit width
        N_layers=> 3,-- number of layers
        L1=> 64,-- number of neurons for 1st layer
        L2=> 32, -- number of layers for 2nd layer
        L3=> 10-- number of neurons for output layer 
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        PARAM_BUFFER_RESET=> PARAM_BUFFER_RESET,
        PARAM_SRC=> PARAM_SRC,
        PARAM_DEST=> PARAM_DEST,
        START=> FULL,
        RX_DONE=> RX_DONE,
        OL=> OL,
        IL=> IL,
        RE=> RE,
        WRE=> WRE,
        EMPTY=> EMPTY,
        ACTIVATION_FIFO_RESET=> ACTIVATION_FIFO_RESET,
        ACTIVATION_SRC=> ACTIVATION_SRC,
        COMPUTE_EN=> COMPUTE_EN,
        CLR_ACC=> CLR_ACC
    );
    mac_array_requantized: entity work.mac_array_requantized
    generic map(
        N=> 8,
        K=> 6
    )
    port map(
        CLK=> CLK,
        CLR_ACC=> CLR_ACC,
        COMPUTE_EN=> COMPUTE_EN,
        X_IN=> DATABUS_OUT,
        PARAMS=> signed(PARAMS_OUT),-- parameter buffer--> mac units
        MAC_ARRAY_OUT_REQUANT=> MAC_ARRAY_OUT_REQUANT
    );
    mac_array: entity work.mac_array
    generic map(
        N=> 8,
        K=> 6
    )
    port map(
        CLK=> CLK, 
        CLR_ACC=> CLR_ACC,
        COMPUTE_EN=> COMPUTE_EN,
        X_IN=> DATABUS_OUT,
        PARAMS=> signed(PARAMS_OUT),
        MAC_ARRAY_OUT=> MAC_ARRAY_OUT
    );
    data_bus_mux: entity work.data_bus_mux
    generic map(
        N=> 8
    )
    port map(
        DATABUSES=> DATABUSES,
        DATABUS=> DATABUS_OUT,
        SEL=> IL
    );
    input_buffer: entity work.input_buffer
    generic map(
        N=> 8,
        X=> 6,
        WRITE_CYCLES=> 8860
    )
    port map(
        CLK=> CLK, 
        RESET=> RESET,
        FULL=> FULL, 
        RX_DONE=> RX_DONE,
        EMPTY=> EMPTY,
        WRE=> WRE,
        RE=> RE,
        RE_TICK=> COMPUTE_EN,
        RX_IN=> RX_IN,
        MODE=> MODE,
        D_OUT=> FIFO_OUT
    );
    clk_proc: process
    begin
        loop
            CLK<= '0';
            wait for 5.8823ns;
            CLK<= '1';
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
        TX_IN<= X"FB";
        SEND<= '1';
        wait until TX_DONE= '1';
        TX_IN<= X"F2";
        wait until TX_DONE= '1';
        TX_IN<= X"FE";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"FD";
        wait until TX_DONE= '1';
        TX_IN<= X"00";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"FF";
        wait until TX_DONE= '1';
        TX_IN<= X"02";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"0E";
        wait until TX_DONE= '1';
        TX_IN<= X"FE";
        wait until TX_DONE= '1';
        TX_IN<= X"09";
        wait until TX_DONE= '1';
        TX_IN<= X"09";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"0D";
        wait until TX_DONE= '1';
        TX_IN<= X"FC";
        wait until TX_DONE= '1';
        TX_IN<= X"0C";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"F5";
        wait until TX_DONE= '1';
        TX_IN<= X"03";
        wait until TX_DONE= '1';
        TX_IN<= X"FC";
        wait until TX_DONE= '1';
        TX_IN<= X"0B";
        wait until TX_DONE= '1';
        TX_IN<= X"08";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"FB";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"FB";
        wait until TX_DONE= '1';
        TX_IN<= X"0E";
        wait until TX_DONE= '1';
        TX_IN<= X"02";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"FA";
        wait until TX_DONE= '1';
        TX_IN<= X"0E";
        wait until TX_DONE= '1';
        TX_IN<= X"0F";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"0B";
        wait until TX_DONE= '1';
        TX_IN<= X"02";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"F6";
        wait until TX_DONE= '1';
        TX_IN<= X"FD";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"0B";
        wait until TX_DONE= '1';
        TX_IN<= X"FF";
        wait until TX_DONE= '1';
        TX_IN<= X"05";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"F9";
        wait until TX_DONE= '1';
        TX_IN<= X"F0";
        wait until TX_DONE= '1';
        TX_IN<= X"10";
        wait until TX_DONE= '1';
        TX_IN<= X"FE";
        wait until TX_DONE= '1';
        TX_IN<= X"F9";
        wait until TX_DONE= '1';
        TX_IN<= X"00";
        wait until TX_DONE= '1';
        TX_IN<= X"0E";
        wait until TX_DONE= '1';
        TX_IN<= X"01";
        wait until TX_DONE= '1';
        TX_IN<= X"F8";
        wait until TX_DONE= '1';
        TX_IN<= X"F3";
        wait until TX_DONE= '1';
        TX_IN<= X"FC";
        wait until TX_DONE= '1';
        SEND<= '0';
        wait;
    end process;
end architecture rtl;