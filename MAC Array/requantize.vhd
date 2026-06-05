library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity requantize is
    generic(
        N: integer:= 8;-- bitwidth
        X: integer:= 4 --number of times to right shift
    );
    port (
        D_IN: in signed(2*N-1 downto 0);
        D_OUT: out signed(N -1 downto 0 )
    );
end entity requantize;

architecture rtl of requantize is
    signal d_out_signal : signed(2*N -1 downto 0);
begin
    d_out_signal<= shift_right(D_IN, X);
    
    D_OUT<= to_signed(127,8) when d_out_signal> to_signed(127,8) else --clamping max
            to_signed(-128,8) when d_out_signal< to_signed(-128,8) else --clamping min
            resize(d_out_signal,8);  
 
end architecture rtl;