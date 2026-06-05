library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_divider is
    generic(
        WRITE_CYCLES: integer:= 10500;-- corresponds to a period of 105us
        READ_CYCLES: integer:= 50000-- corresponds to a period of 500us
    );
    port (
        CLK: in std_logic;
        RESET: in std_logic;
        RE_TICK: out std_logic;
        WRE_TICK: out std_logic
    );
end entity clock_divider;

architecture rtl of clock_divider is
    signal wre_counter, re_counter: integer;
begin
    RE_TICK_PROC: process (CLK) is
    begin
        if rising_edge(CLK) then
            if RESET = '0' then
                if re_counter< READ_CYCLES then
                    RE_TICK<= '0';
                    re_counter<= re_counter + 1;
                else
                    re_counter<= 0;
                    RE_TICK<= '1';
                end if;
            else
                re_counter<= 0;
                RE_TICK<= '0';
            end if;
        end if;
    end process;
    WRE_TICK_PROC: process (CLK) is
    begin
        if rising_edge(CLK) then
            if RESET = '0' then
                if wre_counter< WRITE_CYCLES then
                    WRE_TICK<= '0';
                    wre_counter<= wre_counter + 1;
                else
                    wre_counter<= 0;
                    WRE_TICK<= '1';
                end if;
            else
                wre_counter<= 0;
                WRE_TICK<= '0';
            end if;
        end if;
    end process;
end architecture rtl;