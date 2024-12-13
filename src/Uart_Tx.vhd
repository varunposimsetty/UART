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
    signal baud_clk : std_ulogic := '0';
    signal parity_bit : std_ulogic := '0';
    signal start_sync : std_ulogic := '0';
    signal tx_reg : std_ulogic := '1'; -- because stop bit is 1 and it goes low once the tranmission of data begins 
    signal count : integer := 0;
    signal tx_data : std_ulogic_vector(10 downto 0) := (others => '0');
    signal tx_done : std_ulogic := '0';

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
            tx_data <= (others =>'0');
        elsif (rising_edge(baud_clk)) then
            start_sync <= start;
            if (count > 0 and count <= 10) then -- just incase start goes low during the tx process
                start_sync <= '1';
            end if;
            if (start = '0') then -- idle state 
                tx_reg <= '1';
                count <= 0;
                tx_done <= '0';
                tx_data <= (others => '0');
            elsif (start_sync = '1') then 
                tx_data <= start_bit & data_in & parity_bit & stop_bit;
                if (count < 10) then 
                    tx_done <= '0';
                    tx_reg <= tx_data(count);
                    count <= count + 1;
                elsif (count = 10) then
                    tx_reg <= tx_data(count);
                    count <= 0;
                    tx_done <= '1';
                end if;
            end if;
        end if;
    end process proc_tx;
    tx <= tx_reg;
    ready <= tx_done;
end architecture RTL;