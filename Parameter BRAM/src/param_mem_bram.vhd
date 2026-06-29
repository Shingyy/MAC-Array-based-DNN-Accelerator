library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity param_mem_bram is
    generic(
        N : integer := 8;
        K : integer := 13
    );
    port(
        CLK     : in  std_logic;
        CLR     : in  std_logic; -- unused unless BMG reset enabled
        WRE     : in  std_logic;
        ADDR    : in  std_logic_vector(K-1 downto 0);
        D_WRITE : in  std_logic_vector(N-1 downto 0);
        D_READ  : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture rtl of param_mem_bram is

    signal wea_sig : std_logic_vector(0 downto 0);

begin

    wea_sig(0) <= WRE;

    param_bram_inst : entity work.blk_mem_gen_0
    port map (
        clka  => CLK,
        ena   => '1',
        rsta  => CLR,
        wea   => wea_sig,
        addra => ADDR,
        dina  => D_WRITE,
        douta => D_READ
    );

end architecture;