-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--
-- NMult entity declaration
--

entity NMult is
    generic (
        N : integer := 8;  -- Number of bits to pad out to
        M : integer := 2   -- Number of mutiplications by 10
    );
    port (
        X      : in  unsigned(3 downto 0);    -- Number to multiply
        result : out unsigned(N - 1 downto 0) -- M * 10 * X
    );
end NMult;


--
-- NMult dataFlow architecture
--

architecture dataFlow of NMult is

    --
    -- Component declaration of Mult10
    --

    component Mult10 is
        generic (
            N : integer  -- Number of digits to pad all numbers out to
        );
        port (
            X      : in  unsigned(3 downto 0);    -- Number to multiply
            result : out unsigned(N - 1 downto 0) -- 10 * x
         );
    end component;

    type uns_array is array (0 to M - 2) of unsigned(N - 1 downto 0);

    signal products : uns_array;

begin
    U1: Mult10 generic map (
        N => N
    )
    port map(
        X => X,
        result => products(0)
    );

    gen_products: for i in 1 to M-2 generate
        UX : Mult10 generic map(
            N => N
        )
        port map (
            X => products(i - 1),
            result => products(i)
        );
    end generate gen_products;

    UM: Mult10 generic map (
        N => N
    )
    port map(
        X => products(M - 2),
        result => result
    );
end dataFlow;
