-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--
-- Mult10 entity declaration
--

entity Mult10 is
    generic (
        N : integer := 8 -- Number of digits to pad all numbers out to
    );
    port (
        X      : in  unsigned(3 downto 0);    -- Number to multiply
        result : out unsigned(N - 1 downto 0) -- 10 * x
    );
end Mult10;


--
-- Mult10 dataFlow architecture
--

architecture dataFlow of Mult10 is
begin
    result <= (resize(X, N) sll 3) + (resize(X, N) sll 1);
end dataFlow;
