library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity activation_buffer is
    generic(
        N:integer := 8;--bit width for each activation
        K: integer := 2-- corresponds to 2^K activations
    );
    port (
        CLK: in std_logic;
        ADDR: in std_logic_vector(K-1 downto 0);
        RESET: in std_logic;
        ACTIVATIONS: in std_logic_vector(2**K *N -1 downto 0);
        ACTIVATION_OUT: out std_logic_vector(N-1 downto 0)
    );
end entity activation_buffer;

architecture rtl of activation_buffer is
    signal buffer_registers: std_logic_vector(2**K *N -1 downto 0);--buffer registers to temporarily store activations
begin
    clk_proc: process (CLK) is
    begin
        if rising_edge(CLK) then
            if RESET= '0' then
                buffer_registers<= ACTIVATIONS;
            else
                buffer_registers<= std_logic_vector(to_unsigned(0,2**K *N));--clears all the registers
            end if;
        end if;
    end process;
    ACTIVATION_OUT<=    (others=> '0') when ADDR(0)= 'Z' else
                        buffer_registers((to_integer(unsigned(ADDR))+1)*N-1 downto to_integer(unsigned(ADDR))*N);--select specified activation as per register address 
end architecture rtl;