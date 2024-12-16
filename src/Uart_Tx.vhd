library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity Uart_Tx is 
    port (
        i_clk_100MHz  : in std_ulogic;
        i_nrst_async  : in std_ulogic;
        data_in       : in std_ulogic_vector(7 downto 0);
        start         : in std_ulogic;
        parity_enable : in std_ulogic;
        parity_mode   : in std_ulogic;
        tx            : out std_ulogic;
        ready         : out std_ulogic 
    );
end entity Uart_Tx;

architecture RTL of Uart_Tx is 
    -- signals for baud_clk 
    signal baud_clk : std_ulogic := '0';
    -- signals for parity
    signal parity_bit : std_ulogic := '0';
    -- signals for UART_Tx
    constant start_bit : std_ulogic := '0';
    constant stop_bit  : std_ulogic := '1';
    signal tx_reg : std_ulogic := '1'; -- during idle state tx is high
    signal tx_reg_buffer : std_ulogic_vector(10 downto 0) := (others => '0');
    signal data_buffer : std_ulogic_vector(7 downto 0) := (others => '0');
    shared variable count : integer := 0;
    signal tx_complete : std_ulogic := '0';
    
    type state is (IDLE,INITIAL,DATA,PARITY,LAST);
    signal tx_state : state := IDLE;

begin 
    DUT_CLK_BAUD : entity work.ClkDivider(RTL)
    port map(
        i_clk_100MHz => i_clk_100MHz,
        i_nrst_async => i_nrst_async,
        clk_out => baud_clk
    );

    DUT_Parity : entity work.ParityLogic(RTL)
        port map(
            data_in => data_in,
            parity_enable => parity_enable,
            parity_mode => parity_mode,
            parity_out => parity_bit
        );
    
    proc_tx : process(baud_clk, i_nrst_async)
        variable data_bit_count : integer := 0;
    begin 
        if (i_nrst_async = '0') then 
            tx_reg <= '1';
            data_buffer <= (others => '0');
            count := 0;
            tx_state <= IDLE;
            tx_complete <= '0';
        elsif rising_edge(baud_clk) then 
            
            case tx_state is 
                when IDLE =>
                    tx_reg <= '1';
                    data_buffer <= (others => '0');
                    count := 0;
                    tx_complete <= '0';
                    if (start = '1') then 
                        data_buffer <= data_in;
                        tx_reg_buffer <= start_bit & data_in & stop_bit & stop_bit;
                        tx_state <= INITIAL;
                        count := count + 1;
                    else 
                        tx_state <= IDLE;
                    end if;
                when INITIAL =>
                    tx_reg <= start_bit;
                    count := count + 1;
                    tx_state <= DATA;
                    data_bit_count := 0;
                    when DATA => 
                    if data_bit_count < 8 then
                        tx_reg <= data_buffer(data_bit_count);
                        data_bit_count := data_bit_count + 1;
                        count := count + 1;
                    else
                        data_bit_count := 0;
                        if (parity_enable = '1') then
                            tx_state <= PARITY;
                            count := count + 1;
                        else 
                            tx_state <= LAST;
                            count := count + 2;
                        end if;
                    end if;
                when PARITY =>
                            tx_reg <= parity_bit;
                            count := count + 1;
                            tx_state <= LAST;
                when LAST =>
                            tx_reg <= stop_bit;
                            tx_complete <= '1';
                            tx_state <= IDLE;
            end case;
            end if;
    end process proc_tx;
    tx <= tx_reg;
    ready <= tx_complete;
end architecture RTL;