library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity two_to_four_mux is
    port (
        D_IN: in std_logic_vector(1 downto 0);
        D_OUT: out std_logic_vector(3 downto 0)
    );
end entity two_to_four_mux;

architecture rtl of two_to_four_mux is
    
begin
    D_OUT<= std_logic_vector(to_unsigned(0,4)) when D_IN= std_logic_vector(to_unsigned(1,2)) else
            std_logic_vector(to_unsigned(1,4)) when D_IN= std_logic_vector(to_unsigned(2,2)) else
            std_logic_vector(to_unsigned(10,4));  
end architecture rtl;