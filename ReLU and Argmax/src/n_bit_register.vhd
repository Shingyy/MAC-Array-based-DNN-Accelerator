library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity n_bit_register is
    generic(
        N: integer:= 8
    );
    port (
        D: in signed(N-1 downto 0);
        CLK: in std_logic;
        R: in std_logic;
        Q: out signed(N-1 downto 0)
    );
end entity n_bit_register;

architecture rtl of n_bit_register is
begin
    process (R,CLK) is
    begin
        if R='1' then
            Q<= to_signed(0,N);
        else
            if rising_edge(CLK) then
                Q<= D;
            end if;
        end if;
    end process;
end architecture rtl;