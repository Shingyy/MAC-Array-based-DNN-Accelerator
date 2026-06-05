library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic(
        N: integer:= 8
    );
    port (
        CLK_RX: in std_logic;--clock
        RX_IN: in std_logic;-- Reception dataline
        RX_DATA: out std_logic;-- data reception in progress
        RX_DONE: out std_logic;-- data reception complete
        RESET_RX: in std_logic;--reset UART RX FSM
        MAX_CYCLE: in unsigned(14 downto 0);--number of total cycles for 1 bit period minus 1 (determined by Baud Generator)
        D_OUT: out std_logic_vector(N-1 downto 0);--recieved data
        SAMPLE_TICK: out std_logic-- Shows where the FSM is sampling
    );
end entity uart_rx;

architecture rtl of uart_rx is
    type uart_states is (IDLE, START, DATA, STOP);--UART FSM States
    signal uart_state: uart_states;
    signal edge_count: integer;-- counts the number of data bits received
    signal counter: unsigned(14 downto 0);--counts every clock period and overflows after it reaches bit period
    signal run_counter: std_logic:= '0';--initiates counter 
    signal rxin_prev: std_logic:= '0';-- previous value of RX_IN
    signal rxdone, rxdata: std_logic;
    signal rx_capture: std_logic;
    signal rx_launch: std_logic:= '1';
begin
    two_FF_sync: process (CLK_RX) is 
    begin
        if rising_edge(CLK_RX) then
            rx_launch<= RX_IN;
            rx_capture<= rx_launch;
        end if;
    end process;
    fallingedge_detect: process (CLK_RX) is
    begin
        if rising_edge(CLK_RX) then
                rxin_prev<= rx_capture;
        end if;
    end process;
    uart_rx: process (CLK_RX)
    begin
        if rising_edge(CLK_RX) then
            if RESET_RX= '1' then --reset FSM
                uart_state<= IDLE;
                rxdone<= '0';
                rxdata<= '0';
                D_OUT<= std_logic_vector(to_unsigned(0, 8));
            else
                if rxin_prev= '1' and rx_capture= '0' then-- falling edge
                    if uart_state= IDLE then
                        run_counter<= '1';--starts counter
                        uart_state<= START; 
                    end if;
                end if;
                if counter= MAX_CYCLE/2 -1 then-- starts sampling at T/2 where T is bit period
                    SAMPLE_TICK<= '1';
                    case uart_state is
                        when IDLE=>
                            rxdone<= '0';
                            rxdata<= '0';
                        when START=> 
                                edge_count<= 0;
                                uart_state<= DATA;
                        when DATA=>
                            if edge_count< N then
                                rxdata<= '1';--data reception in progress
                                D_OUT(edge_count)<= rx_capture;-- Data captured LSB First
                                edge_count<= edge_count + 1; 
                            else
                                rxdata<= '0';--no data reception
                                rxdone<= '1';--data recption complete
                                uart_state<= STOP;
                            end if;
                        when STOP=> 
                            if rx_capture= '1' then
                                rxdone<= '0';
                                run_counter<= '0';
                                uart_state<= IDLE;
                            end if;
                    end case;
                else
                    SAMPLE_TICK<= '0';
                end if;
            end if;
        end if;
    end process;
    RX_DATA<= rxdata;
    RX_DONE<= rxdone;
    --Counter
    counter_proc: process (CLK_RX) is
    begin
        if rising_edge(CLK_RX) then
            if RESET_RX= '0' then
                if run_counter= '1' then
                    if counter< MAX_CYCLE then
                        counter<= counter+ 1;--counts the number of clock cycles until bit period 
                    else 
                        counter<= to_unsigned(0,15);-- counter overflow
                    end if;
                else
                    counter<= to_unsigned(0,15);--counter reset
                end if;
            else 
                counter<= to_unsigned(0,15);--counter reset
            end if;    
        end if;
    end process;
end architecture rtl;