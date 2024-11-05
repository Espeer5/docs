--------------------------------------------------------------------------------
--                                                                            --
--  BCD2BinaryN logic design                                                  --
--                                                                            --
--  This is an entity and architecture declaration for an n-digit BCD to      --
--  binary converter. The design assumes that the input will be a valid BCD   --
--  value of the given n digits.                                              --
--                                                                            --
--  Inputs:                                                                   --
--           BCD[n..0] - n-digit BCD input                                    --
--                                                                            --
--  Outputs:                                                                  --
--           B[n..0]   - n-bit binary output                                  --
--                                                                            --
--  Revision History:                                                         --
--      10/27/24  Edward Speer    Initial Revision                            --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--
-- BCD2BinaryN entity declaration
--

entity BCD2BinaryN is
    generic (
        N : integer    -- Parameterize the converter by the number of digits
    );
    port (
        BCD : in  std_logic_vector(4 * N - 1 downto 0);
        B   : out std_logic_vector(4 * N - 1 downto 0)
    );
end BCD2BinaryN;


--
-- BCD2BinaryN dataFlow architecture
--

architecture dataFlow of BCD2BinaryN is

    --
    -- component declaration of NMult
    --
    component NMult is
        generic (
            N : integer;  -- Number of bits to pad out to
            M : integer   -- Number of mutiplications by 10
        );
        port (
            X      : in unsigned(3 downto 0);     -- Number to multiply
            result : out unsigned(N - 1 downto 0) -- M * 10 * X
        );
    end component;

    type uns_array is array (0 to N - 2) of unsigned(4 * N - 1 downto 0);

    signal sums         : uns_array;
    signal partial_sums : uns_array;

begin
    gen_sums: for i in 1 to N-1 generate
        UX : NMult generic map (
            N => 4 * N,
            M => i
        )
        port map (
            X => unsigned(BCD(4 * i + 3 downto 4 * i)),
            result => sums(i - 1)
        );
    end generate gen_sums;

    partial_sums(0) <= sums(0);

    gen_total: for i in 1 to N - 2 generate
        partial_sums(i) <= partial_sums(i - 1) + sums(i);
    end generate gen_total;

    B <= std_logic_vector(
        partial_sums(N - 2) + resize(unsigned(BCD(3 downto 0)), 4 * N)
    );
    
end dataFlow;
