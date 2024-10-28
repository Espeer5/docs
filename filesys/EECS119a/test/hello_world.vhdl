library ieee;
use ieee.std_logic_1164.all;

entity HelloWorld is
end HelloWorld;

architecture Behavioral of HelloWorld is
begin
    process
    begin
        report "Hello, World!";
        wait;  -- Stops the process after printing
    end process;
end Behavioral;
