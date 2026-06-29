library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity activation_fifo is
    generic(
        N: integer:= 8;
        X: integer:= 2
    );
    port (
        CLK, RESET, RE_TICK, WRE, RE: in std_logic;
        ACTIVATION_IN: in signed(N-1 downto 0);
        EMPTY: out std_logic;
        FULL: out std_logic;
        ACTIVATION_OUT: out signed(N-1 downto 0)
    );
end entity activation_fifo;

architecture rtl of activation_fifo is
    
begin
    my_fifo: entity work.fifo
    generic map(
        N=> N,
        X=> X
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        RE_TICK=> RE_TICK,
        WRE_TICK=> '1',
        RE=> RE,
        WRE=> WRE,
        D_IN=> ACTIVATION_IN,
        D_OUT=> ACTIVATION_OUT,
        EMPTY=> EMPTY,
        FULL=> FULL,
        ALMOST_EMPTY=> open,
        ALMOST_FULL=> open
    );
end architecture rtl;