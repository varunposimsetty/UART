library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

-- BAUD Rate is the rate at which communication takes place over the UART Channel 
-- Typical BAUD Rates : 9600,19200,38400,57600,115200 bps
-- 

entity ClkDivider is 
    generic (
        BAUD_RATE : integer := 115200
    );
    port (
        i_clk_100MHz : in std_ulogic;
        i_nrst_async : in std_ulogic;
        clk_out      : out std_ulogic
    );
end entity ClkDivider;

architecture RTL of ClkDivider is 
    constant CLK_FREQ : real := 100.0e6;
    constant DIV_COUNT : integer := integer(ceil(CLK_FREQ/ real(BAUD_RATE)));
    constant LIMIT : integer := integer(DIV_COUNT/2);
    signal count : integer range 0 to LIMIT-1 := 0;
    signal clk_reg : std_ulogic := '0';
begin 
    process(i_clk_100MHz,i_nrst_async)
    begin 
        if (i_nrst_async = '0') then
            count <= 0;
            clk_reg <= '0';
        elsif (rising_edge(i_clk_100MHz)) then
            if (count = LIMIT-1) then
                clk_reg <= not clk_reg;
                count <= 0;
            else 
                count <= count + 1;
            end if;
        end if;
    end process;
    clk_out <= clk_reg;
end architecture RTL;