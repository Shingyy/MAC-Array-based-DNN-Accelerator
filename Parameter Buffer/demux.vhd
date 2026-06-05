library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity demux is
    generic(
        N: integer:= 4
    );
    port (
        SEL: in unsigned(N-1 downto 0);
        RESET: in std_logic;
        DEMUX_OUT: out std_logic_vector(2**N-1 downto 0)
    );
end entity demux;

architecture rtl of demux is
    signal demux_signal: unsigned(2**N -1 downto 0);
begin  
    demux_signal<= shift_left(to_unsigned(1, 2**N),to_integer(SEL));--shift to the left SEL times 

    DEMUX_OUT<= std_logic_vector(demux_signal) when RESET='0' else-- Active high reset 
                std_logic_vector(to_unsigned(1, 2**N));
end architecture rtl;