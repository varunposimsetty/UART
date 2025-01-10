library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity Uart_Rx is 
    port (
    i_clk_100MHz    : in std_ulogic;
    i_nrst_async    : in std_ulogic;
    rx              : in std_ulogic;
    parity_enable   : in std_ulogic;
    parity_mode     : in std_ulogic;
    data_out        : out std_ulogic_vector(7 downto 0);
    data_ready      : out std_ulogic;
    parity_error    : out std_ulogic;
    framing_error   : out std_ulogic
    );
end entity Uart_Rx;

architecture RTL of Uart_Rx is 
    -- signals for baud_clk 
    signal baud_clk : std_ulogic := '0';
    -- signals for parity
    signal parity_bit : std_ulogic := '0';
    signal error_parity : std_ulogic := '1';
    -- signals for UART rx 
    signal rx_reg_buffer : std_ulogic_vector(10 downto 0) := (others => '0');
    signal data_buffer : std_ulogic_vector(7 downto 0) := (others => '0');
    signal rx_word : std_ulogic_vector(7 downto 0) := (others => '0');
    
    



begin 
    DUT_CLK_BAUD : entity work.ClkDivider(RTL)
    port map(
        i_clk_100MHz => i_clk_100MHz,
        i_nrst_async => i_nrst_async,
        clk_out => baud_clk
    );

    DUT_Parity : entity work.ParityLogic(RTL)
        port map(
            data_in => rx_reg_buffer(9 downto 2),
            parity_enable => parity_enable,
            parity_mode => parity_mode,
            parity_out => parity_bit
    );

    proc_rx : process(baud_clk,i_nrst_async) is 
        begin 
            if (i_nrst_async = '0') then 
                rx_reg_buffer <= (others => '0');
                data_buffer <= (others => '0');
                
            elsif (rising_edge(baud_clk)) then 
                rx_reg_buffer <= rx_reg_buffer(9 downto 0) & rx;
                if (rx_reg_buffer(10) = '0') and (rx_reg_buffer(0) = '1') then
                    rx_word <= rx_reg_buffer(9 downto 2);
                    framing_error <= '0';
                    if (parity_enable = '1') then
                        if (parity_mode = '0') then
                            if (parity_bit = rx_reg_buffer(1)) then 
                                data_buffer <= rx_word;
                                error_parity <= '0';  
                            else 
                                error_parity <= '1';              
                            end if;
                        elsif (parity_mode = '1') then 
                            if (parity_bit = rx_reg_buffer(1)) then 
                                data_buffer <= rx_word;
                                error_parity <= '0';
                            else 
                                error_parity <= '1';
                            end if;   
                        end if; 
                    elsif(parity_enable = '0') then 
                        rx_word <= rx_reg_buffer(9 downto 2);
                        if (rx_reg_buffer(1) = '1' and rx_reg_buffer(0) = '1') then 
                            data_buffer <= rx_word;
                            parity_error <= '0';
                        else 
                            parity_error <= '1';
                        end if;
                    end if; 
                    data_ready <= '1';
                else 
                    framing_error <= '1';
                    data_ready <= '0';
                end if;
            end if;
    end process proc_rx;
    data_out <= data_buffer;
end architecture RTL;


