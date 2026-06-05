library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_bus_mux is
    generic(
        N: integer:= 8--bit width for each databus
    );
    port (
        DATABUSES: in signed(2*N-1 downto 0);
        DATABUS: out signed(N-1 downto 0);
        SEL: in std_logic
    );
end entity data_bus_mux;

architecture rtl of data_bus_mux is
    
begin
    DATABUS<= DATABUSES(2*N-1 downto N) when SEL= '1' else
              DATABUSES(N-1 downto 0);
end architecture rtl;