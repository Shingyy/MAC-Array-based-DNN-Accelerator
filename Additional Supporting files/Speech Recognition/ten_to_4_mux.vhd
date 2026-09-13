library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ten_to_4_mux is
    port (
        D_IN: in std_logic_vector(9 downto 0);
        D_OUT: out std_logic_vector(3 downto 0)
    );
end entity ten_to_4_mux;

architecture rtl of ten_to_4_mux is
    
begin
    D_OUT<= std_logic_vector(to_unsigned(0,4)) when D_IN= std_logic_vector(to_unsigned(1,10)) else
            std_logic_vector(to_unsigned(1,4)) when D_IN= std_logic_vector(to_unsigned(2,10)) else
            std_logic_vector(to_unsigned(2,4)) when D_IN= std_logic_vector(to_unsigned(4,10)) else
            std_logic_vector(to_unsigned(3,4)) when D_IN= std_logic_vector(to_unsigned(8,10)) else
            std_logic_vector(to_unsigned(4,4)) when D_IN= std_logic_vector(to_unsigned(16,10)) else
            std_logic_vector(to_unsigned(5,4)) when D_IN= std_logic_vector(to_unsigned(32,10)) else
            std_logic_vector(to_unsigned(6,4)) when D_IN= std_logic_vector(to_unsigned(64,10)) else
            std_logic_vector(to_unsigned(7,4)) when D_IN= std_logic_vector(to_unsigned(128,10)) else
            std_logic_vector(to_unsigned(8,4)) when D_IN= std_logic_vector(to_unsigned(256,10)) else
            std_logic_vector(to_unsigned(9,4)) when D_IN= std_logic_vector(to_unsigned(512,10)) else
            std_logic_vector(to_unsigned(10,4)) ;  
end architecture rtl;