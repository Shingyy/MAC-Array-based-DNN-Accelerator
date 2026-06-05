library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo is
    generic(
        N: integer := 8;-- FIFO width
        X: integer := 3-- 2**X FIFO depth
    );
    port (
        CLK: in std_logic;
        RESET: in std_logic;
        D_IN: in signed(N-1 downto 0);
        RE_TICK: in std_logic;
        WRE_TICK: in std_logic;
        D_OUT: out signed(N-1 downto 0);
        WRE: in std_logic;--write enable
        RE: in std_logic;--read enable
        FULL: out std_logic;
        ALMOST_FULL: out std_logic;
        EMPTY: out std_logic;
        ALMOST_EMPTY: out std_logic
    );
end entity fifo;

architecture rtl of fifo is
    signal rd_ptr_launch,wr_ptr_launch,rd_ptr_capture,wr_ptr_capture, rd_ptr, wr_ptr : unsigned(X downto 0):= (others=> '0');-- adding 1 extra bit to the pointers
    type fifo_array is array(0 to 2**X -1) of signed(N-1 downto 0);
    signal my_fifo: fifo_array;
    attribute ram_style : string;
    attribute ram_style of my_fifo : signal is "block";
    signal d_out_signal: signed(N-1 downto 0);
    
begin
    write_process: process (CLK) is
    begin
        if rising_edge(CLK) then
            if RESET= '0' then 
                --2FF synchronizer
                rd_ptr_launch<= rd_ptr;
                rd_ptr_capture<= rd_ptr_launch;
                if WRE= '1' and WRE_TICK = '1' then
                    if rd_ptr_capture(X)=wr_ptr(X) then
                        my_fifo(to_integer(wr_ptr(X-1 downto 0)))<= D_IN;
                        wr_ptr<=wr_ptr + 1;
                    end if;
                end if;
            else
               wr_ptr<= (others=> '0');
            end if;
        end if;
    end process; 
    read_process: process (CLK) is
    begin
        if rising_edge(CLK) then
            if RESET= '0' then
                --2FF synchronizer
                wr_ptr_launch<= wr_ptr;
                wr_ptr_capture<= wr_ptr_launch;
                if RE= '1' and RE_TICK= '1' then
                    if not(rd_ptr= wr_ptr_capture) then
                        d_out_signal<= my_fifo(to_integer(rd_ptr(X-1 downto 0)));
                        rd_ptr<= rd_ptr + 1;
                    end if;
                end if;
            else
                d_out_signal<= (others=> '0');
                rd_ptr<= (others=> '0');
            end if;
        end if;
    end process; 
    ALMOST_FULL<= '1' when wr_ptr(X-1 downto 0) + 3= rd_ptr(X-1 downto 0) and WRE= '1' else '0'; 
    ALMOST_EMPTY<= '1' when wr_ptr(X-1 downto 0) = rd_ptr(X-1 downto 0) + 3  and RE= '1' else '0';
    FULL<= '1' when  rd_ptr= to_unsigned(2**X,X+1) and wr_ptr= to_unsigned(0,X+1) else 
           '1' when wr_ptr= to_unsigned(2**X,X+1) and rd_ptr= to_unsigned(0,X+1) else   
           '0';
    EMPTY<= '1' when rd_ptr= wr_ptr else '0';
    D_OUT<= d_out_signal;
end architecture rtl;