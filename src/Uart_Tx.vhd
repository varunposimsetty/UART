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
    signal count : integer := 0;
    signal tx_complete : std_ulogic := '1'; -- the Tx is free initially and is ready to transmit.
    
    

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

    proc_tx : process (baud_clk,i_nrst_async) is 
        begin 
            if (i_nrst_async = '0') then 
                tx_reg <= '1';
                data_buffer <= (others => '0');
                count <= 0;
                tx_complete <= '1';
            elsif (rising_edge(baud_clk)) then 
                
                if (start = '1' and tx_complete = '1') then 
                    count <= 0;
                    data_buffer <= (others => '0');
                    tx_reg_buffer <= (others => '0');
                else 
                    count <= count + 1;
                end if;

                case count is 

                    when 0 =>
                        tx_complete <= '0';
                        data_buffer <= data_in;
                        if (parity_enable = '1') then 
                            tx_reg_buffer <= start_bit & data_in & parity_bit & stop_bit;
                        else 
                            tx_reg_buffer <= start_bit & data_in & stop_bit & stop_bit;
                        end if;
                    
                    when 1 =>
                        tx_reg <= tx_reg_buffer(10);
                        tx_reg_buffer <= tx_reg_buffer(9 downto 0) & '0';
                    
                    when 2 to 9 =>
                        tx_reg <= tx_reg_buffer(10);
                        tx_reg_buffer <= tx_reg_buffer(9 downto 0) & '0';
                    
                    when 10 =>
                        if (parity_enable = '1') then 
                            tx_reg <= tx_reg_buffer(10);
                            tx_reg_buffer <= tx_reg_buffer(9 downto 0) & '0';
                        else 
                            tx_reg <= tx_reg_buffer(10);
                            tx_reg_buffer <= tx_reg_buffer(9 downto 0) & '0';
                        end if;
                    when 11 =>
                        tx_reg <= tx_reg_buffer(10);
                        tx_reg_buffer <= tx_reg_buffer(9 downto 0) & '0';
                        tx_complete <= '1';
                        count <= 0;
                    when others =>
                        null;
                
                end case;
            end if;
        end process proc_tx;
        tx <= tx_reg;
        ready <= tx_complete;
end architecture RTL;