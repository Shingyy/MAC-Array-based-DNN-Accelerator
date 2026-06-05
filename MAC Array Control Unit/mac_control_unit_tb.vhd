library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mac_control_unit_tb is
end entity mac_control_unit_tb;

architecture rtl of mac_control_unit_tb is
    signal CLK, RESET, COMPUTE_EN, CLR_ACC, OL, IL, START: std_logic;
    signal PARAM_SRC, ACTIVATION_DEST: std_logic_vector(9 downto 0);
    signal PARAM_DEST: std_logic_vector(1 downto 0);
    signal ACTIVATION_SRC: std_logic_vector(1 downto 0);
begin
    mac_control_unit_obj: entity work.mac_control_unit
    port map(
        CLK=> CLK,
        RESET=> RESET,
        START=> START,
        COMPUTE_EN=> COMPUTE_EN,
        CLR_ACC=> CLR_ACC,
        PARAM_SRC=> PARAM_SRC,
        PARAM_DEST=> PARAM_DEST,
        ACTIVATION_DEST=> ACTIVATION_DEST,
        ACTIVATION_SRC=> ACTIVATION_SRC,
        OL=> OL,
        IL=> IL
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
        START<= '0';
        wait for 20ns;
        RESET<= '0';
        START<= '1';
        wait for 10ns;
        START<= '0';
        wait;
    end process;
end architecture rtl;