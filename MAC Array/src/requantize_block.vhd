library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity requantize_block is
    generic(
        N: integer:= 8;
        K: integer:= 2
    );
    port (
        D_IN_BUS: in  signed(2**K * 2*N -1 downto 0);
        D_OUT_BUS: out signed(2**k * N -1 downto 0)
        );
end entity requantize_block;

architecture rtl of requantize_block is
    
begin
    requantize_objects: for i in 0 to 2**K -1 generate
        requantize_object: entity work.requantize
        generic map(
            N=> N
        )
        port map(
            D_IN=> D_IN_BUS((i+1)*2*N -1 downto i*2*N),
            D_OUT=> D_OUT_BUS((i+1)*N -1 downto i*N)
        );
    end generate;

end architecture rtl;