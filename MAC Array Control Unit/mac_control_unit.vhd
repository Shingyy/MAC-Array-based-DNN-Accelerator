library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mac_control_unit is
    generic(
        Input_vector_length: integer:= 5;
        Neurons: integer:= 8; --number of neurons for the particular layer
        N: integer:= 8;--bit width
        K: integer:= 2;-- 2**K MAC units
        X: integer:= 10;-- Parameter BRAM Address bit width
        Y: integer:= 10;-- Activations BRAM Address bit width 
        N_layers: integer := 3;-- number of layers
        L1: integer:= 4;-- number of neurons for 1st layer
        L2: integer:= 2; -- number of layers for 2nd layer
        L3: integer:= 1-- number of neurons for output layer 
    );
    port (
        CLK: in std_logic;
        RESET: in std_logic;
        START: in std_logic;
        PARAM_SRC: out std_logic_vector(X-1 downto 0);--Paramater BRAM
        PARAM_DEST: out std_logic_vector(K-1 downto 0);--Parameter Buffer
        ACTIVATION_SRC: out std_logic_vector(K-1 downto 0); --Activations Buffer
        ACTIVATION_DEST: out std_logic_vector(Y-1 downto 0);-- Activations BRAM
        COMPUTE_EN: out std_logic;--Compute enable signal for the MAC ARRAY
        CLR_ACC: out std_logic;-- Clear Accumulator signal for the MAC Array
        OL: out std_logic;--Output Layer Flag
        IL: out std_logic-- Input Layer Flag
    );
end entity mac_control_unit;

architecture rtl of mac_control_unit is
    signal dist_counter: unsigned(K-1 downto 0);-- distribution counter
    signal param_counter: unsigned(X-1 downto 0);
    signal activation_counter: unsigned(Y-1 downto 0);
    signal compute_cycle: unsigned(X-1 downto 0);
    signal layer: unsigned(1 downto 0);--current layer being computed
    signal activation_en,param_en: std_logic;--enabling distribution counter to either param DEMUX or Activation MUX 
    type STATES is (IDLE, FETCH, COMPUTE, STORE, CLEAR);
    signal current_state : STATES;
    signal param_delay: std_logic;
    signal base_addr: unsigned(X-1 downto 0);
    signal activation_delay: unsigned(1 downto 0);
    signal fetch_delay: unsigned(1 downto 0);
    type neural_network is array(0 to 2) of unsigned(K downto 0);
    constant NEURAL_NET_TOPOLOGY: neural_network:= (
        0=> to_unsigned(L1,K+1),
        1=> to_unsigned(L2,K+1),
        2=> to_unsigned(L3,K+1)
    );
     signal neurons_per_layer: neural_network := NEURAL_NET_TOPOLOGY;
begin
    sync_process: process (RESET, CLK) is
    begin
        if rising_edge(CLK) then
            if RESET= '1' then
                dist_counter<= to_unsigned(0,K);
                param_counter<= to_unsigned(0,X);
                activation_counter<= to_unsigned(0,Y);
                compute_cycle<= to_unsigned(1,X);
                base_addr<= to_unsigned(1,X);
                layer<= to_unsigned(0,2);
                current_state<= IDLE;
                COMPUTE_EN<= '0';
                CLR_ACC<= '0';
                activation_en<= '0';
                param_en<= '1';
                param_delay<= '0';
                activation_delay<= "00";
            else
                case current_state is
                    when IDLE =>
                        dist_counter<= to_unsigned(0,K);
                        param_counter<= to_unsigned(0,X);
                        activation_counter<= to_unsigned(0,Y);
                        compute_cycle<= to_unsigned(1,X);
                        layer<= to_unsigned(0,2);
                        COMPUTE_EN<= '0';
                        CLR_ACC<= '0';
                        activation_en<= '0';
                        param_en<= '1';
                        param_delay<= '0';
                        activation_delay<= "00";
                        if START= '1' then 
                            current_state<= FETCH;
                        end if;
                    when FETCH =>
                        CLR_ACC<= '0';
                        COMPUTE_EN<= '0';
                        if dist_counter< neurons_per_layer(to_integer(layer)) -1 then
                            if param_delay= '1' then
                                dist_counter <= dist_counter + to_unsigned(1,K);
                            else
                                param_delay<= '1';
                            end if;
                        --ensure param counter only gets 2**K cycles despite the dist counter delay
                            if param_counter< base_addr + (neurons_per_layer(to_integer(layer)) -1 )*(Input_vector_length+1) -1 then 
                                param_counter<= param_counter+ to_unsigned(Input_vector_length+1, X);
                            end if;
                        else
                            current_state<= COMPUTE;
                        end if;    
                    when COMPUTE =>
                        COMPUTE_EN<= '1';
                        param_delay<= '0';
                        fetch_delay<= "00";
                        compute_cycle<= compute_cycle + to_unsigned(1,N);
                        base_addr<= base_addr + to_unsigned(1,N);
                        dist_counter<= to_unsigned(0,K);
                        if compute_cycle < to_unsigned(Input_vector_length+1 , X) then
                            param_counter<= base_addr;
                            current_state<= FETCH;
                        else
                            param_en<= '0';
                            activation_en<= '1';
                            current_state<= STORE;
                        end if;
                    when STORE=> 
                        param_en<= '0';
                        activation_en<= '1';
                        COMPUTE_EN<= '0';
                        if dist_counter< neurons_per_layer(to_integer(layer)) -1 then
                            if activation_delay< to_unsigned(3,2) then
                                activation_delay<= activation_delay+ to_unsigned(1,2);
                            else 
                                dist_counter <= dist_counter + to_unsigned(1,K);
                                activation_counter<= activation_counter + to_unsigned(1,Y);
                            end if;
                        else
                            layer<= layer + to_unsigned(1,2);--setting up next layer transition
                            current_state<= CLEAR;
                        end if;
                    when CLEAR=>
                        CLR_ACC<= '1';
                        if layer< to_unsigned(N_layers,2) then
                            compute_cycle<= to_unsigned(1,X);
                            dist_counter<= (others=> '0');
                            param_en<= '1';
                            activation_en<= '0';
                            param_delay<= '0';
                            activation_delay<= "00";
                            param_counter<= param_counter+ to_unsigned(1,X);--set to parameter source address to the first bias of next layer 
                            base_addr<= param_counter + to_unsigned(2,X);-- base address set to parameter source address + 2
                            current_state<= FETCH;
                        else
                            current_state<= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;
    PARAM_SRC<= std_logic_vector(param_counter);
    PARAM_DEST<= std_logic_vector(dist_counter) when param_en='1' else (others=> 'Z');
    ACTIVATION_SRC<= std_logic_vector(dist_counter) when activation_en='1' else (others=> 'Z');
    ACTIVATION_DEST<= std_logic_vector(activation_counter);
    OL<= '1' when layer= to_unsigned(N_layers-1, 2) else  '0' ;--output layer flag
    IL<= '1' when layer= to_unsigned(0,2) else '0';--input layer flag
end architecture rtl;