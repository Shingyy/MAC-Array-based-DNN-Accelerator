library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_mac is
    generic(
        N: integer:= 8
    );
    port (
        CLK: in std_logic;
        PARAM: in signed(N-1 downto 0);
        X_IN: in signed(N-1 downto 0);
        CLR_ACC: in std_logic;
        COMPUTE_EN: in std_logic;
        MAC_OUT: out signed(2*N-1 downto 0)
    );
end entity serial_mac;

architecture rtl of serial_mac is
    signal acc: signed(2*N-1 downto 0):= (others=> '0');--accumulator
    signal is_weight: std_logic:= '0';-- 1st parameter is always a bias
    
    attribute use_dsp : string;
    attribute use_dsp of acc : signal is "yes";
begin
    clk_proc: process (CLK) is
    begin
        if rising_edge(CLK) then
            if CLR_ACC= '0' then
                if COMPUTE_EN= '1' then
                    if is_weight= '0' then 
                        acc<= resize(PARAM, 2*N);
                    else
                        acc<= PARAM*X_IN + acc;
                    end if;
                    is_weight<=  '1';
                end if;
            else
                is_weight<= '0';
                acc<= (others=>'0');
            end if;
        end if;
    end process;
    MAC_OUT<= acc ;
end architecture rtl;
