library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--this module connects the uart rx module with the baud generator module
entity top_uart_rx is
    generic(
        N: integer:= 8
    );
    port (
        MODE: in std_logic_vector(1 downto 0);
        CLK: in std_logic;
        RESET: in std_logic;
        RX_IN: in std_logic;
        RX_DATA: out std_logic;
        RX_DONE: out std_logic;
        D_OUT: out std_logic_vector(N-1 downto 0);
        SAMPLE_TICK: out std_logic
    );
end entity top_uart_rx;

architecture rtl of top_uart_rx is
    signal max_cycle: unsigned(14 downto 0);
begin
    uart_receiver: entity work.uart_rx
    port map(
        CLK_RX=> CLK,
        RX_IN=> RX_IN,
        RX_DATA=> RX_DATA,
        RX_DONE=> RX_DONE,
        RESET_RX=> RESET,
        MAX_CYCLE=> max_cycle,
        D_OUT=> D_OUT,
        SAMPLE_TICK=> SAMPLE_TICK
    );
    baud_generator: entity work.baud_gen
    port map(
        MODE=> MODE,
        CLK_BAUD=> CLK,
        RESET_BAUD=> RESET,
        BAUD_TICK=> open,
        MAX_CYCLE=> max_cycle,
        BAUD_TICK_OUT=> open
    );
end architecture rtl;