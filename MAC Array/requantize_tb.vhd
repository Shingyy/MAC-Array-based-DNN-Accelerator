library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity requantize_tb is
end entity requantize_tb;

architecture rtl of requantize_tb is
    signal D_IN: signed(15 downto 0);
    signal D_OUT: signed(7 downto 0);
begin
    requantize_obj: entity work.requantize
    port map(
        D_IN=> D_IN,
        D_OUT=> D_OUT
    );
    stim_proc: process 
    begin
        D_IN<= to_signed(128,16);
        wait for 10ns;
        D_IN<= to_signed(1024,16);
        wait for 10ns;
        D_IN<= to_signed(-2048,16);
        wait for 10ns;
        D_IN<= to_signed(7800,16);
        wait for 10ns;
        D_IN<= to_signed(-5000,16);
        wait for 10ns;
        D_IN<= to_signed(12800,16);
        wait ;
    end process;
    
end architecture rtl;