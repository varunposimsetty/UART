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
    signal tx_reg_buffer_sync : std_ulogic_vector(10 downto 0) := (others => '0');
    signal count : integer := 0;
    signal tx_complete : std_ulogic := '0';




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