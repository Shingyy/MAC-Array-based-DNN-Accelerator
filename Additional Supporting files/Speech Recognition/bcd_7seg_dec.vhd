library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--interface
entity bcd_7seg_dec is
    port (
        BIN_IN: in std_logic_vector(3 downto 0);--binary input
        LED_IN: out std_logic_vector(6 downto 0)-- LED Display input
    );
end entity bcd_7seg_dec;
--behavior
architecture rtl of bcd_7seg_dec is
    
begin
    LED_IN <= std_logic_vector(to_unsigned(1,7)) when BIN_IN="0000" else
             std_logic_vector(to_unsigned(79,7)) when BIN_IN="0001" else
             std_logic_vector(to_unsigned(18,7)) when BIN_IN="0010" else
             std_logic_vector(to_unsigned(6,7)) when BIN_IN="0011" else
             std_logic_vector(to_unsigned(76,7)) when BIN_IN="0100" else
             std_logic_vector(to_unsigned(36,7)) when BIN_IN="0101" else
             std_logic_vector(to_unsigned(32,7)) when BIN_IN="0110" else
             std_logic_vector(to_unsigned(15,7)) when BIN_IN="0111" else
             std_logic_vector(to_unsigned(0,7)) when BIN_IN="1000" else
             std_logic_vector(to_unsigned(4,7)) when BIN_IN="1001" else
             (others=> '1');
end architecture rtl;