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
    signal parity_out : std_ulogic := '0';

    begin 
    DUT_CLK_DIVIDER : entity work.ClkDivider(RTL)
        port map(
            i_clk_100MHz => clk,
            i_nrst_async => rst,
            clk_out => clk_out
        );

    DUT_PARITY : entity work.ParityLogic(RTL)
        port map(
            data_in => data_in,
            parity_enable => parity_enable,
            parity_mode => parity_mode,
            parity_out => parity_out
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
                    rst <= '0';
                    wait for 2500 ns;
                    rst <= '1';
                    wait for 100 ns;
                    parity_enable <= '1';
                    wait for 100000 ns;
                    data_in <= "01010101";
                    wait for 200000 ns;
                    data_in <= "11101010";
                    wait for 200000 ns;
                    data_in <= "01010111";
                    wait for 100000 ns;
                    parity_mode <= '1';
                    wait for 1000000 ns;
                    data_in <= "01000111";
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
end architecture bhv;