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

    begin 
    DUT : entity work.ClkDivider(RTL)
        port map(
            i_clk_100MHz => clk,
            i_nrst_async => rst,
            clk_out => clk_out
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
                    wait for 620000 ns;
                    rst <= '0';
                    wait for 100 ns;
                    rst <= '1';
                    wait;
                end process proc_tb;
end architecture bhv;
