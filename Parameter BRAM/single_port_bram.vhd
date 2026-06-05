library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Single port Block RAM of N words width and 2^K words depth

entity single_port_bram is
    generic(
        N: integer:= 8;-- width 
        K: integer:= 10-- K is the number of bits for address bus and 2^(K) specifies the depth in words
    );
    port(
        CLK: in std_logic;--clock
        CLR: in std_logic; --clears the register at the specified address
        WRE: in std_logic;--write enable
        ADDR: in std_logic_vector(K-1 downto 0);--address bus
        D_WRITE: in std_logic_vector(N-1 downto 0);--write data bus
        D_READ: out std_logic_vector(N-1 downto 0)--read data bus
    );
end entity;

architecture rtl of single_port_bram is
    type bram_array is array(0 to 2**K -1) of std_logic_vector(N-1 downto 0);
    constant INIT : bram_array := (
        0  => x"00",
        1  => x"01",
        2  => x"02",
        3  => x"03",
        4  => x"04",
        5  => x"05",
        6  => x"06",
        7  => x"07",
        8  => x"08",
        9  => x"09",
        10 => x"0A",
        11 => x"0B",
        12 => x"0C",
        13 => x"0D",
        14 => x"0E",
        15 => x"0F",
        16 => x"10",
        17 => x"11",
        18 => x"12",
        19 => x"13",
        20 => x"14",
        21 => x"15",
        22 => x"16",
        23 => x"17",
        24 => x"18",
        25 => x"19",
        26 => x"1A",
        27 => x"1B",
        others => (others => '0')
    );
    signal bram : bram_array := INIT;
begin
    
    bram_proc:process (CLK) is
    begin
        if rising_edge(CLK) then
            if CLR = '0' then
                if WRE= '1' then
                    bram(to_integer(unsigned(ADDR)))<= D_WRITE;
                end if;
            else
                bram(to_integer(unsigned(ADDR)))<= (others=> '0');-- clear signal is independent of the write enable signal
            end if;
            D_READ<= bram(to_integer(unsigned(ADDR)));
        end if;
    end process;
end architecture;