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
    constant start_bit : std_ulogic := '0';
    constant stop_bit : std_ulogic := '1';
    constant data_length : integer := 8;
    signal baud_clk : std_ulogic := '0';
    signal parity_bit : std_ulogic := '0';
    signal start_sync : std_ulogic := '0';
    signal tx_reg : std_ulogic := '1'; -- because stop bit is 1 and it goes low once the tranmission of data begins 
    signal count : integer := 0;
    signal tx_data : std_ulogic_vector(10 downto 0) := (others => '0');
    signal tx_done : std_ulogic := '0';

    type state is (IDLE,START_TX,DATA,PARITY,STOP_TX);
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
    
    proc_tx : process(baud_clk,i_nrst_async)
    begin 
        if (i_nrst_async = '0') then
            tx_reg <= '1';
            count <= 0;
            tx_done <= '0';
            tx_data <= (others => '0');
        elsif (rising_edge(baud_clk)) then 
            start_sync <= start;
            case tx_state is
                when IDLE => 
                    tx_reg <= '1';
                    count <= 0;
                    tx_done <= '0';
                    if (start_sync <= '1') then
                        tx_state <= START_TX;
                    else 
                        tx_state <= IDLE;
                    end if;
                when START_TX =>
                    tx_reg <= start_bit;
                    count <= 0;
                    tx_state <= DATA;
                when DATA =>
                    if (count = data_length-1) then
                        tx_reg <= data_in(count);
                        if (parity_enable = '1') then 
                            tx_state <= PARITY;
                        else 
                            tx_state <= STOP_TX;
                        end if;
                    else 
                        tx_reg <= data_in(count);
                        count <= count + 1; 
                    end if;
                when PARITY =>
                        tx_reg <= parity_bit;
                        tx_state <= STOP_TX;
                when STOP_TX =>
                        tx_reg <= stop_bit;
                        tx_done <= '1';
                        tx_state <= IDLE;
            end case;
        end if;
    end process proc_tx;
    tx <= tx_reg;
    ready <= tx_done;
end architecture RTL;


proc_tx : process(baud_clk,i_nrst_async) is
    begin 
    if (i_nrst_async = '0') then
        tx_reg <= '1';
        tx_reg_buffer <= (others => '0');
    elsif (rising_edge(baud_clk)) then
        if (parity_enable = '1') then
            tx_reg_buffer <= start_bit & data_in & parity_bit & stop_bit;
        else 
            tx_reg_buffer <= start_bit & data_in & stop_bit & stop_bit; -- the stop bit is taken twice to maintain the width of the tx_reg_buffer
        end if;
        if (start = '1') and (tx_complete = '1') then 
            tx_complete <= '0';
            tx_reg_buffer_sync <= tx_reg_buffer;
        end if;
        if (parity_enable = '1') then
            if (count = 10) then 
                tx_reg <= tx_reg_buffer_sync(10);
                tx_complete <= '1';
                tx_reg_buffer_sync <= (others => '0');
                count <= 0;
            else 
                tx_reg <= tx_reg_buffer_sync(10);
                tx_reg_buffer_sync <= tx_reg_buffer_sync(9 downto 0) & '0';
                count <= count + 1;
            end if;
        else 
            if (count = 9) then 
                tx_reg <= tx_reg_buffer_sync(10);
                tx_complete <= '1';
                tx_reg_buffer_sync <= (others => '0');
                count <= 0;
            else 
                tx_reg <= tx_reg_buffer_sync(10);
                tx_reg_buffer_sync <= tx_reg_buffer_sync(9 downto 0) & '0';
                count <= count + 1;
            end if;
        end if;
    end if;
end process proc_tx;
tx <= tx_reg;
ready <= tx_complete;

end architecture RTL;