library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mac_array is
    generic(
        N: integer:= 8;-- parameter bitwidth
        K: integer:= 2-- 2^K MAC units
    );
    port (
        CLK: in std_logic;
        X_IN: in signed(N-1 downto 0); 
        PARAMS: in signed((2**K)*N-1 downto 0);
        CLR_ACC: in std_logic;
        COMPUTE_EN: in std_logic;
        MAC_ARRAY_OUT: out signed((2**(K+1))*N -1 downto 0)
    );
end entity mac_array;

architecture rtl of mac_array is
    
begin
    mac_units: for i in 0 to 2**K- 1 generate
        mac_unit: entity work.serial_mac
        generic map(
            N=> N
        )
        port map(
            CLK=> CLK,
            X_IN=> X_IN,
            PARAM=> PARAMS((i+1)*N -1 downto i*N),
            CLR_ACC=> CLR_ACC,
            COMPUTE_EN=> COMPUTE_EN,
            MAC_OUT=> MAC_ARRAY_OUT(2*(i+1)*N -1 downto i*2*N)
        );
    end generate;
    
end architecture rtl;