library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dnn_accelerator is
     generic(
        Input_vector_length: integer:= 2;
        N: integer:= 8;--bit width
        K: integer:= 6;-- 2**K MAC units
        X: integer:= 13;-- Parameter BRAM depth
        N_layers: integer := 3;-- number of layers
        L1: integer:= 64;-- number of neurons for 1st layer
        L2: integer:= 32; -- number of layers for 2nd layer
        L3: integer:= 10;-- number of neurons for output layer 
        bram_depth: integer:= 13;
        fifo_depth: integer:= 6;
        WRITE_CYCLES: integer:= 8860
    );
    port (
        CLK: in std_logic;
        RESET: in std_logic;
        RX_IN: in std_logic;
        MODE: in std_logic_vector(1 downto 0);
        DIGIT_DISPLAY: out std_logic_vector(6 downto 0)
    );
end entity dnn_accelerator;

architecture rtl of dnn_accelerator is
    signal COMPUTE_EN, CLR_ACC, OL, IL, WRE, RE, ACTIVATION_FIFO_RESET,PARAM_BUFFER_RESET, EMPTY ,FULL, RX_DONE: std_logic;
    signal PARAM_SRC : std_logic_vector(bram_depth-1 downto 0);
    signal PARAM_DEST, ACTIVATION_SRC: std_logic_vector(K-1 downto 0);
    signal PARAMS_OUT: std_logic_vector(2**K*N-1 downto 0);
    signal D_OUT: std_logic_vector(N-1 downto 0); 
    signal MAC_ARRAY_OUT_REQUANT: signed(2**K *N-1 downto 0);
    signal ACTIVATION_BUFFER_OUT: std_logic_vector(N-1 downto 0);
    signal ACTIVATION_OUT: signed(N-1 downto 0);
    signal DATABUS_OUT, FIFO_OUT: signed(N-1 downto 0);
    signal DATABUSES: signed(2*N-1 downto 0);
    signal ACCUMMULATIONS_OUT: signed(2**(K+1) *N-1 downto 0);
    signal ACTVNS_OUT: signed(2**K *N-1 downto 0);
    signal ARGMAX_OUT: std_logic_vector(L3-1 downto 0);
    signal TO_BCD_ENC: std_logic_vector(3 downto 0);
    signal locked_sig, clk_85MHz, reset_gate: std_logic;
begin
    DATABUSES(2*N-1 downto N)<= FIFO_OUT;
    DATABUSES(N-1 downto 0)<= ACTIVATION_OUT;
    reset_gate<= not(locked_sig) or RESET ;
    clk_wiz_inst : entity work.clk_wiz_0
    port map (
        clk_in1  => CLK,   
        clk_out1 => clk_85MHz,    
        reset    => '0',
        locked   => locked_sig
    );
    relu_block: entity work.relu_block
    generic map(
        N=> N,
        K=> K
    )
    port map(
        ACCS=> ACCUMMULATIONS_OUT(2**K*N-1 downto 0),
        ACTIVATIONS_OUT=> ACTVNS_OUT
    );
    argmax: entity work.argmax
    generic map(
        N=> N,
        M=> L3-- number of neurons in the output layer
    )
    port map(
        CLK=> clk_85MHz,
        RESET=> reset_gate,
        ACCS=> ACCUMMULATIONS_OUT(2**K*N + L3*N -1 downto 2**K* N),
        ACTIVATIONS=> ARGMAX_OUT
    );
    ten_to_4_mux: entity work.ten_to_4_mux
    port map(
        D_IN=> ARGMAX_OUT,
        D_OUT=> TO_BCD_ENC
    );
    bcd_7seg_dec: entity work.bcd_7seg_dec
    port map(
        BIN_IN=> TO_BCD_ENC,
        LED_IN=>DIGIT_DISPLAY
    );
    accum_demux: entity work.accum_demux
    generic map(
        N=> N,
        K=> K
    )
    port map(
        ACCUMMULATIONS_IN=> MAC_ARRAY_OUT_REQUANT,
        ACCUMMULATIONS_OUT=> ACCUMMULATIONS_OUT,
        SEL=> OL
    );
    parameter_bram: entity work.parameter_bram
    generic map(
        N=> N,
        K=> bram_depth
    )
    port map(
        CLK=> clk_85MHz,
        CLR=> '0',
        PARAM_ADDR=> PARAM_SRC,
        PARAM_OUT=> D_OUT
    );
    activation_fifo: entity work.activation_fifo
    generic map(
        N=> N,
        X=> fifo_depth
    )
    port map(
        CLK=> clk_85MHz,
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
        N=> N,
        K=> K
    )
    port map(
        CLK=> clk_85MHz,
        RESET=> reset_gate,
        ADDR=> ACTIVATION_SRC,
        ACTIVATIONS=> std_logic_vector(ACTVNS_OUT),
        ACTIVATION_OUT=> ACTIVATION_BUFFER_OUT
    );
    param_buffer: entity work.param_buffer
    generic map(
        N=> N,
        K=> K
    )
    port map(
        PARAM_IN=> D_OUT,
        CLK=> clk_85MHz,
        RESET=> PARAM_BUFFER_RESET,
        ADDR=> PARAM_DEST,
        PARAMS_OUT=> PARAMS_OUT
    );
    mac_control_unit: entity work.mac_control_unit
    generic map(
        Input_vector_length=> 2,-- X_IN should be a 2-vector
        N=> N,--bit width
        K=> K,-- 2**K MAC units
        X=> X,-- Parameter BRAM Address bit width
        N_layers=> N_layers,-- number of layers
        L1=> L1,-- number of neurons for 1st layer
        L2=> L2, -- number of layers for 2nd layer
        L3=> L3-- number of neurons for output layer 
    )
    port map(
        CLK=> clk_85MHz,
        RESET=> reset_gate,
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
        N=> N,
        K=> K
    )
    port map(
        CLK=> clk_85MHz,
        CLR_ACC=> CLR_ACC,
        COMPUTE_EN=> COMPUTE_EN,
        X_IN=> DATABUS_OUT,
        PARAMS=> signed(PARAMS_OUT),-- parameter buffer--> mac units
        MAC_ARRAY_OUT_REQUANT=> MAC_ARRAY_OUT_REQUANT
    );
    data_bus_mux: entity work.data_bus_mux
    generic map(
        N=> N
    )
    port map(
        DATABUSES=> DATABUSES,
        DATABUS=> DATABUS_OUT,
        SEL=> IL
    );
    input_buffer: entity work.input_buffer
    generic map(
        N=> N,
        X=> fifo_depth,
        WRITE_CYCLES=> WRITE_CYCLES
    )
    port map(
        CLK=> clk_85MHz, 
        RESET=> reset_gate,
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
end architecture rtl;