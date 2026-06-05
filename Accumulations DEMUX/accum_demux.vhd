library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accum_demux is
    generic(
        N: integer:= 8;--bit width
        K: integer:= 2-- 2^K MAC units
    );
    port (
       ACCUMMULATIONS_IN: in signed(2**K*N-1 downto 0);
       ACCUMMULATIONS_OUT: out signed(2**(K+1)*N-1 downto 0);
       SEL: in std_logic
    );
end entity accum_demux;

architecture rtl of accum_demux is
    
begin
    
    ACCUMMULATIONS_OUT(2**(K+1)*N-1 downto 2**K*N) <= ACCUMMULATIONS_IN when SEL= '1' else (others=>'0');
    ACCUMMULATIONS_OUT(2**(K)*N-1 downto 0) <= ACCUMMULATIONS_IN when SEL= '0' else (others=>'0');

end architecture rtl;