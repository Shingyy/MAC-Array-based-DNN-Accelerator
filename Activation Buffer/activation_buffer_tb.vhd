library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity activation_buffer_tb is
end entity activation_buffer_tb;

architecture rtl of activation_buffer_tb is
    signal CLK, RESET: std_logic;
    signal ACTIVATIONS: std_logic_vector(31 downto 0);
    signal ADDR: std_logic_vector(1 downto 0);
    signal ACTIVATION_OUT: std_logic_vector(7 downto 0);
begin
    activation_buffer_obj: entity work.activation_buffer
    generic map(
        K=> 2
    )
    port map(
        CLK=> CLK,
        RESET=> RESET,
        ACTIVATIONS=> ACTIVATIONS,
        ADDR=>ADDR,
        ACTIVATION_OUT=> ACTIVATION_OUT
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
        ADDR<= "00";
        ACTIVATIONS<= X"00000000";
        RESET<= '1';
        wait for 20ns;
        ADDR<= "00";-- address for 20h
        ACTIVATIONS<= X"01a41f20";-- activations are 01h, A4h, 1Fh and 20h
        RESET<= '0';
        wait for 20ns;
        ADDR<= "01";--address for 1Fh
        ACTIVATIONS<= X"01a41f20";
        wait for 20ns;
        ADDR<= "10";--address for A4h
        ACTIVATIONS<= X"01a41f20";
        wait for 20ns;
        ADDR<= "11";--address for 01h
        ACTIVATIONS<= X"01a41f20";
        wait;
    end process;
end architecture rtl;