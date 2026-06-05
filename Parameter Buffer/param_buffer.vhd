library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity param_buffer is
    generic(
        N: integer:= 8;--number of bits per parameter
        K: integer:= 2--number of bits for DEMUX selector
    );
    port (
        PARAM_IN: in std_logic_vector(N-1 downto 0);
        ADDR: in unsigned(K-1 downto 0);
        RESET: in std_logic;
        CLK: in std_logic;
        PARAMS_OUT: out std_logic_vector((2**K * N)-1 downto 0)
    );
end entity param_buffer;

architecture rtl of param_buffer is
    signal demux_out: std_logic_vector(2**K-1 downto 0);
begin
    my_demux: entity work.demux
    generic map(
        N=> K
    )
    port map(
        SEL=> ADDR,
        RESET=> RESET,
        DEMUX_OUT=> demux_out
    );
    my_buffer_registers: for i in 0 to 2**K -1 generate
        buffer_register: entity work.buffer_reg
        generic map(
            N=> N
        )
        port map(
            D=> PARAM_IN,
            CLK=> CLK,
            R=> RESET,
            WR_EN=> demux_out(i),
            Q=> PARAMS_OUT(N*(i+1) -1 downto N*i)
        );
    end generate;
    
end architecture rtl;