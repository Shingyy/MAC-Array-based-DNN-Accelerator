library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comparator is
    generic(
        N: integer:= 8
    );
    port (
        A: in signed(N-1 downto 0);
        B: in signed(N-1 downto 0);
        INDEX: out unsigned(0 downto 0);
        MAX: out signed(N-1 downto 0)
    );
end entity comparator;

architecture rtl of comparator is
    
begin
    MAX<= A when A > B else B;
    INDEX<= to_unsigned(0,1) when A> B else to_unsigned(1,1);
end architecture rtl;