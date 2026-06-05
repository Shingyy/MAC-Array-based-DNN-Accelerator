library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity param_buffer_tb is
end entity param_buffer_tb;

architecture rtl of param_buffer_tb is
    signal PARAM_IN: std_logic_vector(7 downto 0);
    signal ADDR: unsigned(1 downto 0);
    signal CLK, RESET: std_logic;
    signal PARAMS_OUT: std_logic_vector(31 downto 0);
begin
    param_buffer_obj: entity work.param_buffer
    generic map(
        K=> 2
    )
    port map(
        PARAM_IN=> PARAM_IN,
        ADDR=> ADDR,
        CLK=> CLK,
        RESET=> RESET,
        PARAMS_OUT=> PARAMS_OUT
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
    stim_proc: process
    begin
        RESET<= '1';
        ADDR<= "00";
        PARAM_IN<= std_logic_vector(to_unsigned(0,8));
        wait for 20ns;
        RESET<= '0';
        ADDR<= "00";
        PARAM_IN<= std_logic_vector(to_unsigned(1,8));
        wait for 20ns;
        ADDR<= "01";
        PARAM_IN<= std_logic_vector(to_unsigned(5,8));
        wait for 20ns;
        ADDR<= "10";
        PARAM_IN<= std_logic_vector(to_unsigned(6,8));
        wait for 20ns;
        ADDR<= "11";
        PARAM_IN<= std_logic_vector(to_unsigned(7,8));
        wait ;
    end process;
end architecture rtl;