library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accum_demux_tb is
end entity accum_demux_tb;

architecture rtl of accum_demux_tb is
    signal ACCUMMULATIONS_IN: signed(31 downto 0);
    signal ACCUMMULATIONS_OUT: signed(63 downto 0);
    signal SEL: std_logic;
begin
    accum_demux: entity work.accum_demux
    port map(
        ACCUMMULATIONS_IN=> ACCUMMULATIONS_IN,
        ACCUMMULATIONS_OUT=> ACCUMMULATIONS_OUT,
        SEL=> SEL
    );

    stim_proc: process
    begin
        SEL<= '0';
        ACCUMMULATIONS_IN<= X"23859831";
        wait for 40ns;
        SEL<= '1';
        ACCUMMULATIONS_IN<= X"23859831";
        wait;
    end process;
    
    
end architecture rtl;