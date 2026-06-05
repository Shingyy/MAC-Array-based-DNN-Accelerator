library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity param_bram is
    generic(
        N: integer:= 8;-- BRAM width
        K: integer:= 10-- 2^K BRAM depth
    );
    port (
        PARAM_OUT: out std_logic_vector(N-1 downto 0);
        PARAM_ADDR: in std_logic_vector(K-1 downto 0);
        CLK: in std_logic;
        CLR: in std_logic
    );
end entity param_bram;

architecture rtl of param_bram is
    
begin
   single_port_bram_obj: entity work.single_port_bram
   generic map(
        N=> N,
        K=> K
   ) 
   port map(
        CLK=> CLK,
        CLR=> CLR,
        ADDR=> PARAM_ADDR,
        D_READ=> PARAM_OUT,
        D_WRITE=> (others=> '0'),
        WRE =>  '0'
   );
end architecture rtl;
