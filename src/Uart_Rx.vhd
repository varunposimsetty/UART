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

    proc_rx : process(i_clk_100MHz,i_nrst_async) is 
        begin 
            if (i_nrst_async = '0') then 
                









end architecture RTL;


