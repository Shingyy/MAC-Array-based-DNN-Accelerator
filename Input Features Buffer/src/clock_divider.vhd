library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_divider is
    generic(
        WRITE_CYCLES: integer:= 10500;-- number of clock cycles between each write tick
        READ_CYCLES: integer:= 50000-- number of clock cycles between each read tick
    );
    port (
        CLK: in std_logic;-- clock
        RESET: in std_logic;
        RE_TICK: out std_logic;-- Read tick output
        WRE_TICK: out std_logic --Write tick output
    );
end entity clock_divider;

architecture rtl of clock_divider is
    signal wre_counter, re_counter: integer;-- write and read counters respectively
begin
    RE_TICK_PROC: process (CLK) is
    begin
        if rising_edge(CLK) then
            if RESET = '0' then
                -- read counter overflows after reaching the specified read clock cycles
                if re_counter< READ_CYCLES then
                    RE_TICK<= '0';
                    re_counter<= re_counter + 1;
                else
                    re_counter<= 0;-- reset read counter
                    RE_TICK<= '1';-- read tick pulse after the specified read cycles
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
                -- write counter overflows after reaching the specified read clock cycles
                if wre_counter< WRITE_CYCLES then
                    WRE_TICK<= '0';
                    wre_counter<= wre_counter + 1;
                else
                    wre_counter<= 0;-- reset write counter
                    WRE_TICK<= '1';-- read tick pulse after the specified read cycles
                end if;
            else
                wre_counter<= 0;
                WRE_TICK<= '0';
            end if;
        end if;
    end process;
end architecture rtl;