library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity relu is
    generic(
        N: integer:= 8
    );
    port (
        ACC: in signed(N-1 downto 0);
        ACTIVATION: out signed(N-1 downto 0)
    );
end entity relu;

architecture rtl of relu is
    
begin
    
    ACTIVATION<= ACC when ACC> to_signed(0,N) else (others=> '0') ;
    
end architecture rtl;