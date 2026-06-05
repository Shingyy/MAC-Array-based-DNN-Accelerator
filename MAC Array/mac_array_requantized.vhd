library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mac_array_requantized is
    generic(
        N: integer:= 8;
        K: integer:= 2
    );
    port(
        CLK: in std_logic;
        X_IN: in signed(N-1 downto 0); 
        PARAMS: in signed((2**K)*N-1 downto 0);
        CLR_ACC: in std_logic;
        COMPUTE_EN: in std_logic;
        MAC_ARRAY_OUT_REQUANT: out signed((2**(K))*N -1 downto 0)-- Requantized MAC ARRAY output
    );
end entity mac_array_requantized;

architecture rtl of mac_array_requantized is
    signal mac_array_signal: signed((2**(K+1))*N -1 downto 0);
begin
    --MAC ARRAY
    mac_array_obj: entity work.mac_array
    generic map(
        N=> N,
        K=> K
    )
    port map(
        CLK=> CLK,
        X_IN=> X_IN,
        PARAMS=> PARAMS,
        CLR_ACC=> CLR_ACC,
        COMPUTE_EN=> COMPUTE_EN,
        MAC_ARRAY_OUT=> mac_array_signal
    );
    --REQUANTIZATION BLOCK
    requantize_block_obj: entity work.requantize_block
    generic map(
        N=> N,
        K=> K
    )
    port map(
        D_IN_BUS=> mac_array_signal,
        D_OUT_BUS=> MAC_ARRAY_OUT_REQUANT
    );
end architecture rtl;