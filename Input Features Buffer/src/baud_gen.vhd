library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

entity baud_gen is
    port(
        MODE: in std_logic_vector(1 downto 0);
        CLK_BAUD: in std_logic;
        RESET_BAUD: in std_logic;
        BAUD_TICK: out std_logic;
        MAX_CYCLE: out unsigned(14 downto 0);
        BAUD_TICK_OUT: out std_logic
    );
end entity;

architecture rtl of baud_gen is
    signal counter: unsigned(14 downto 0);
    signal n_cycles: unsigned(14 downto 0);
    signal bd_tick: std_logic;
begin
    baud_generate: process (MODE) is
        begin
          case MODE is 
            when "00" => n_cycles<= to_unsigned(20832,15);--4800 baud
            when "01" => n_cycles<= to_unsigned(10415, 15);--9600 baud
            when "10" => n_cycles<= to_unsigned(5207, 15);--19200 baud
            when "11" => n_cycles<= to_unsigned(2603, 15);-- 38400 baud
            when others => n_cycles<= to_unsigned(20832, 15);
          end case;  
    end process;
    uart_clk_generate: process (CLK_BAUD, RESET_BAUD) is
        begin
            if RESET_BAUD= '1' then 
                counter<= to_unsigned(0, 15);
                bd_tick<= '0';
            else
                if rising_edge(CLK_BAUD) then
                    if counter< n_cycles then
                        counter<= counter + 1;
                        bd_tick<= '0';
                    else
                        bd_tick<= '1';
                        counter<= to_unsigned(0, 15);
                    end if;
                end if;
            end if;
    end process;
    MAX_CYCLE<= n_cycles;
    BAUD_TICK <= bd_tick;
    BAUD_TICK_OUT<= bd_tick;
end architecture;