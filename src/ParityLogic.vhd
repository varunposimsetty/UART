library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity ParityLogic is 
    port (
        data_in       : in std_ulogic_vector(7 downto 0);
        parity_enable : in std_ulogic;
        parity_mode   : in std_ulogic; -- 0 = even parity and 1 = odd parity
        parity_out    : out std_ulogic
    );
end entity ParityLogic;

architecture RTL of ParityLogic is 
begin 
    process (data_in, parity_enable, parity_mode)
    begin 
    if (parity_enable = '1') then
        if (parity_mode = '0') then 
            -- even parity 
            parity_out <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5) xor data_in(6) xor data_in(7);
        elsif (parity_mode = '1') then
            -- odd parity
            parity_out <= not(data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5) xor data_in(6) xor data_in(7));
        end if;
    else 
            parity_out <= '1'; -- if parity is not enabled we could use this parity_bit = '1' as another stop bit i.e. two stop bits "11"
    end if;
    end process;
end architecture RTL;
