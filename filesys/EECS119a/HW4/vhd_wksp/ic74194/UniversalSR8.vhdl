--------------------------------------------------------------------------------
--                                                                            --
--  UniversalSR8 sequential logic design                                      --
--                                                                            --
--  This is an entity and architecture declaration for an 8-bit universal     --
--  shift register. This register is implemented using a pair of 74LS194A     --
--  4-bit shift registers as components. UniversalSR8 includes an             --
--  asynchronous global clear.                                                --
--                                                                            --
--  Inputs:                                                                   --
--           CLK     - Clock Signal                                           --
--           CLR     - Active low asynchronous clear                          --
--           LSI     - Left shift serial input                                --
--           RSI     - Right shift serial input                               --
--           S[1..0] - Select signals for shift register mode mux             --
--           D[7..0] - Parallel data Input                                    --
--                                                                            --
--  Outputs:                                                                  --
--           Q[7..0] - Data buffer/output signals                             --
--                                                                            --
--  Mode Selection:                                                           --
--                  00 => HOLD                                                --
--                  01 => SHIFT RIGHT                                         --
--                  10 => SHIFT LEFT                                          --
--                  11 => LOAD PARALLEL                                       --
--                                                                            --
--  Revision History:                                                         --
--      10/27/24  Edward Speer    Initial Revision                            --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;


--
-- UniversalSR8 entity declaration
--

entity UniversalSR8 is
    port(
        CLK  : in std_logic;                       -- Clock signal
        CLR  : in std_logic;                       -- Active low asynch clear
        LSer : in std_logic;                       -- Left shift serial input
        RSer : in std_logic;                       -- Right shift serial input
        Mode : in std_logic_vector(1 downto 0);    -- Mode mux select signals
        D    : in std_logic_vector(7 downto 0);    -- Parallel data input
        Q    : buffer std_logic_vector(7 downto 0) -- Data outputs
    );
end UniversalSR8;

architecture Structural of UniversalSR8 is

    --
    -- Component declaration of ic74174
    --

    component ic74194 is
        port(
            CLK : in std_logic;                       -- Clock signal
            CLR : in std_logic;                       -- Active low asynch clear
            LSI : in std_logic;                       -- Left shift serial in
            RSI : in std_logic;                       -- Right shift serial in
            S   : in std_logic_vector(1 downto 0);    -- Mode mux select signals
            DI  : in std_logic_vector(3 downto 0);    -- Parallel data input
            DO  : buffer std_logic_vector(3 downto 0) -- Data outputs
        );
    end component;

begin

    -- The lower nibble is one instance of an ic74194
    U1: ic74194 port map (
        CLK => CLK,
        CLR => CLR,
        LSI => LSer,          -- Lower nibble shifts in system LSer on left
        RSI => Q(4),          -- Shift in low bit of upper nibble from right
        S   => Mode,
        DI  => D(3 downto 0), -- Lower nibble is bits 3..0 for I/O
        DO  => Q(3 downto 0)
    );

    -- The upper nibble is a second instance of an ic74194
    U2: ic74194 port map (
        CLK => CLK,
        CLR => CLR,
        LSI => Q(3),          -- Shift in high bit of lower nibble on left
        RSI => RSer,          -- Shift in system RSer on the right
        S   => Mode,
        DI  => D(7 downto 4), -- Upper nibble is bits 7..4 for I/O
        DO  => Q(7 downto 4)
    );

end Structural;
