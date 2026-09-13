library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--interface
entity letter_7seg is
    port (
        BIN_IN: in std_logic_vector(3 downto 0);--binary input
        LED_IN: out std_logic_vector(6 downto 0)-- LED Display input
    );
end entity letter_7seg;
--behavior
architecture rtl of letter_7seg is
    
begin
    LED_IN <= std_logic_vector(to_unsigned(114,7)) when BIN_IN="0000" else
             std_logic_vector(to_unsigned(66,7)) when BIN_IN="0001" else
             std_logic_vector(to_unsigned(99,7)) when BIN_IN="0010" else
             (others=> '1');
end architecture rtl;