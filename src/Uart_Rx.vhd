library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity Uart_Rx is 
    port (
        i_clk_100MHz : in std_ulogic;
        i_nrst_async : in std_ulogic;
        
    )

