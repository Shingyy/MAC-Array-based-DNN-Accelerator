library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mac_array_tb is
end entity mac_array_tb;

architecture rtl of mac_array_tb is
    signal COMPUTE_EN, CLR_ACC, CLK: std_logic;
    signal X_IN: signed(7 downto 0);
    signal PARAMS: signed(31 downto 0);
    signal MAC_ARRAY_OUT: signed(63 downto 0);
begin
    my_mac_array: entity work.mac_array
    port map(
        CLK=> CLK,
        COMPUTE_EN=> COMPUTE_EN,
        CLR_ACC=> CLR_ACC,
        X_IN=> X_IN,
        PARAMS=> PARAMS,
        MAC_ARRAY_OUT=> MAC_ARRAY_OUT
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
    --All Parameters in signed Q4.4 fixed point arithmetic and taken as hexadecimal values
    stim_proc: process
    begin
        CLR_ACC<= '1';
        X_IN<= X"00";
        PARAMS<= X"00000000";
        wait for 20ns;
        --Biases Computation
        CLR_ACC<= '0';
        X_IN<= X"00";--kept zero because the first parameters are always biases
        PARAMS<= X"0308030a";--the respective biases for each MAC unit are 0Ah,08h,03H,0ah 
        wait for 60ns;
        --Weights Computation
        X_IN<= X"10";-- x1= 10h
        PARAMS<= X"0F09050a";--respective weights are 0Fh,09h, 05h, 0Ah 
        wait for 60ns;
        X_IN<= X"17";-- x2= 17h
        PARAMS<= X"070b1700";--respective weights are 07h, 0bh, 17h,00h 
        wait for 60ns;
        X_IN<= X"09";-- x3= 09h
        PARAMS<= X"030d0611";--respective weights are 03h,0dh,06h,11h
        wait for 60ns;
        X_IN<= X"0a";-- x4= 0Ah
        PARAMS<= X"14120c07";--respective weights are 14h,12h,0Ch,07h 
        wait ;
    end process;
end architecture rtl;