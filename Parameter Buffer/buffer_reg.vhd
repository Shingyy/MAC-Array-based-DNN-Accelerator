library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity buffer_reg is
    generic(
        N: integer:= 8
    );
    port (
        D: in std_logic_vector(N-1 downto 0);
        CLK: in std_logic;
        WR_EN: in std_logic;
        R: in std_logic;
        Q: out std_logic_vector(N-1 downto 0)
    );
end entity buffer_reg;

architecture rtl of buffer_reg is
begin
    process (R,CLK) is
    begin
        if R='1' then
            Q<= std_logic_vector(to_unsigned(0,N));
        else
            if rising_edge(CLK) and WR_EN= '1' then
                Q<= D;
            end if;
        end if;
    end process;
end architecture rtl;