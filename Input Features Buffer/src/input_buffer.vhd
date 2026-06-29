library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity input_buffer is
    generic(
        N: integer:= 8;
        X: integer:= 3; --2**X FIFO depth
        WRITE_CYCLES: integer:= 10500;
        READ_CYCLES: integer:= 100000000 
    );
    port (
        CLK: in std_logic;
        RESET: in std_logic;
        RX_IN: in std_logic;
        D_OUT: out signed(N-1 downto 0);
        READ_ENABLE: out std_logic;
        WRITE_ENABLE: out std_logic;
        MODE: in std_logic_vector(1 downto 0);
        RX_DONE: out std_logic
    );
end entity input_buffer;

architecture rtl of input_buffer is
    signal RE, WRE, RXDONE, EMPTY, FULL, RE_TICK, WRE_TICK: std_logic;
    signal D_OUT_signal: std_logic_vector(7 downto 0);
begin
    my_clock_divider: entity work.clock_divider
    generic map(
        WRITE_CYCLES=> WRITE_CYCLES,-- period of 105us
        READ_CYCLES=> READ_CYCLES-- period of 1s
    )
    port map(
        CLK=> CLK,
        RESET=> RESET, 
        WRE_TICK=> WRE_TICK,
        RE_TICK=> RE_TICK
    );
    my_uart_rx: entity work.top_uart_rx
    port map(
        CLK=> CLK,
        RESET=> RESET,
        MODE=> MODE,
        RX_IN=> RX_IN,
        RX_DATA=> open,
        RX_DONE=> RXDONE, --TO MAC Array Control Unit
        D_OUT=> D_OUT_signal,--to FIFO
        SAMPLE_TICK=> open
    );
    my_fifo: entity work.fifo
    generic map(
        X=> X --DEPTH OF 8
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        D_IN=> signed(D_OUT_signal),--FROM THE UART RECEİVER
        D_OUT=> D_OUT,
        EMPTY=> EMPTY,-- To MAC Control Unit
        FULL=> FULL,-- To MAC Control Unit
        RE_TICK=> RE_TICK,
        WRE_TICK=> WRE_TICK,
        ALMOST_EMPTY=> open,
        ALMOST_FULL=> open,
        RE=> RE,-- From MAC Control Unit
        WRE=> WRE-- From MAC Control Unit
    );
    my_mac_control_unit: entity work.mac_control_unit
    port map(
        CLK=> CLK,
        RESET=> RESET,
        START=> FULL,
        RX_DONE=> RXDONE,
        EMPTY=> EMPTY,
        RE=> RE,
        WRE=> WRE,
        PARAM_SRC=> open,
        PARAM_DEST=> open,
        ACTIVATION_SRC=> open,
        ACTIVATION_DEST=> open,
        OL=> open,
        IL=> open,
        COMPUTE_EN=> open,
        CLR_ACC=> open
    );
    RX_DONE<= RXDONE;
    READ_ENABLE<= RE;
    WRITE_ENABLE<= WRE;
end architecture rtl;