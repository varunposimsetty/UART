library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity tb is 
end entity tb;

architecture bhv of tb is
    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '0';
    signal clk_out : std_ulogic := '0';
    signal data_in : std_ulogic_vector(7 downto 0) := (others => '0');
    signal parity_enable : std_ulogic := '0';
    signal parity_mode : std_ulogic := '0';
    signal parity_out : std_ulogic;
    signal start : std_ulogic := '0';
    signal tx : std_ulogic;
    signal ready : std_ulogic := '0';
    signal rx : std_ulogic := '0';
    signal data_out : std_ulogic_vector(7 downto 0) := (others => '0');
    signal data_ready : std_ulogic := '0';
    signal parity_error : std_ulogic := '0';
    signal framing_error : std_ulogic := '1';



    begin 

    DUT_CLK_BAUD : entity work.ClkDivider(RTL)
        port map(
            i_clk_100MHz => clk,
            i_nrst_async => rst,
            clk_out => clk_out
        );

    DUT_Parity : entity work.ParityLogic(RTL)
        port map(
            data_in => data_in,
            parity_enable => parity_enable,
            parity_mode => parity_mode,
            parity_out => parity_out
        );

    DUT_TX : entity work.Uart_Tx(RTL)
        port map(
            i_clk_100MHz => clk,
            i_nrst_async => rst,
            data_in  => data_in,
            start    => start,
            parity_enable => parity_enable,
            parity_mode => parity_mode,
            tx => tx,
            ready => ready
        );

    DUT_RX : entity work.Uart_Rx(RTL)
        port map(
            i_clk_100MHz => clk,
            i_nrst_async => rst,
            rx  => rx,
            parity_enable => parity_enable,
            parity_mode => parity_mode,
            data_out => data_out,
            data_ready => data_ready,
            parity_error => parity_error,
            framing_error => framing_error
        );

        proc_clock_gen : process is
            begin
                wait for 5 ns;
                clk <= not clk;
            end process proc_clock_gen;
        
            
        proc_tb : process is
                begin
                    wait for 1250 ns;
                    rst <= '1';
                    wait for 250000 ns;
                    rst <= '1';
                    wait for 2500 ns;
                    rst <= '1';
                    wait for 100 ns;
                    parity_enable <= '1';
                    wait for 100 ns;
                    start <= '1';
                    wait for 1000 ns;
                    data_in <= "01010101";
                    wait for 200000 ns;
                    data_in <= "11101010";
                    wait for 200000 ns;
                    data_in <= "01010111";
                    wait for 100000 ns;
                    parity_mode <= '1';
                    wait for 1000000 ns;
                    data_in <= "01000111";
                    wait for 2000 ns;
                    start <= '0';
                    wait for 1000 ns;
                    start <= '1';
                    wait for 2000000 ns;
                    data_in <= "10101110";
                    wait for 2000000 ns;
                    data_in <= "11011101";
                    wait for 1000000 ns;
                    data_in <= "10001101";
                    wait for 6200000 ns;
                    rst <= '0';
                    wait for 100 ns;
                    rst <= '1';
                    wait;
        end process proc_tb;

        proc_rx : process is 
            begin 
                wait for 10000 ns;
                rx <= not rx;
            end process proc_rx;
end architecture bhv;
