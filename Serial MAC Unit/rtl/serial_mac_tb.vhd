library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serial_mac_tb is
end entity serial_mac_tb;

architecture rtl of serial_mac_tb is
    signal CLK, CLR_ACC, COMPUTE_EN: std_logic;
    signal X_IN, PARAM: signed(7 downto 0);
    signal MAC_OUT: signed(16 downto 0);

begin
    my_serial_mac: entity work.serial_mac
    port map(
        CLK=> CLK,
        CLR_ACC=> CLR_ACC,
        COMPUTE_EN=> COMPUTE_EN,
        X_IN=> X_IN,
        PARAM=> PARAM,
        MAC_OUT=> MAC_OUT
    );
    clk_proc: process 
    begin
        loop
            CLK<= '0';
            wait for 5ns;
            CLK<= '1';
            wait for 5ns;
        end loop;
    end process;
    compute_en_proc: process
    begin
        COMPUTE_EN<= '0';
        wait for 20ns;
        for i in 0 to 4 loop
            COMPUTE_EN<= '1';
            wait for 10ns;
            COMPUTE_EN<= '0';
            wait for 50ns;
        end loop;
        wait;
    end process;
    stim_proc: process
    begin
        --initialization
        CLR_ACC<= '1';
        X_IN<= to_signed(0, 8);
        PARAM<= to_signed(0, 8);
        wait for 20ns;
        -- bias first
        CLR_ACC<= '0';
        X_IN<= to_signed(0, 8);
        PARAM<= to_signed(56, 8);-- 3.5
        wait for 60ns;
        --w1 and x1
        CLR_ACC<= '0';
        X_IN<= to_signed(24, 8);-- 1.5
        PARAM<= to_signed(32, 8);-- 2
        wait for 60ns;
        --w2 and x2
        CLR_ACC<= '0';
        X_IN<= to_signed(78, 8);-- 4.875
        PARAM<= to_signed(-80, 8);-- -5
        wait for 60ns;
        --w3 and x3
        CLR_ACC<= '0';
        X_IN<= to_signed(-32, 8);-- -2
        PARAM<= to_signed(96, 8);-- 6
        wait for 60ns;
        --w4 and x4
        CLR_ACC<= '0';
        X_IN<= to_signed(60, 8);-- 3.75
        PARAM<= to_signed(127, 8);-- 7.9375
        wait ;
    end process;
end architecture rtl;