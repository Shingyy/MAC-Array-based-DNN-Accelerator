library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_mac is
    generic(
        N: integer:= 8 --bitwidth for each parameter and input feature
    );
    port (
        CLK: in std_logic;
        PARAM: in signed(N-1 downto 0);-- parameter input, bias first
        X_IN: in signed(N-1 downto 0);-- input feature input
        CLR_ACC: in std_logic;-- clear accumulation 
        COMPUTE_EN: in std_logic;-- compute enable
        MAC_OUT: out signed(2*N-1 downto 0) -- final accumulation output
    );
end entity serial_mac;

architecture rtl of serial_mac is
    signal acc: signed(2*N-1 downto 0):= (others=> '0');--accumulator
    signal is_weight: std_logic:= '0';-- weight flag
    
    attribute use_dsp : string;
    attribute use_dsp of acc : signal is "yes";
    
begin
    clk_proc: process (CLK) is
    begin
        if rising_edge(CLK) then
            if CLR_ACC= '0' then
                if COMPUTE_EN= '1' then
                    if is_weight= '0' then 
                        acc<= resize(shift_left(PARAM,4), 2*N);-- load bias
                    else
                        acc<= PARAM*X_IN + acc; -- MAC operation( y= wx +b)
                    end if;
                    is_weight<=  '1';
                end if;
            else
                is_weight<= '0';
                acc<= (others=>'0');-- clear accumulator
            end if;
        end if;
    end process;
    MAC_OUT<= acc ;
end architecture rtl;
