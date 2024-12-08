--------------------------------------------------------------------------------
--                                                                            --
--  CORDIC16 logic design                                                     --
--                                                                            --
--  This is an entity declaration and architecture for a fully parallel       --
--  16 bit CORDIC calculator. The unit takes in two 16 bit signed Q1.14       --
--  fixed point numbers and calculates an operation on them based on a 5 bit  --
--  function selection control signal. The unit computes the result of any    --
--  operation in a single clock cycle.                                        --
--                                                                            --
--  Available operations are:                                                 --
--      00001 - cos(x)                                                        --
--      00101 - sin(x)                                                        --
--      00100 - x * y                                                         --
--      00010 - cosh(x)                                                       --
--      00110 - sinh(x)                                                       --
--      01100 - y / x                                                         --
--                                                                            --
--  Inputs:                                                                   --
--           x[15..0] - First input 16 bit signed Q1.14 fixed point number    --
--           y[15..0] - Second input 16 bit signed Q1.14 fixed point number   --
--           f[4..0]  - Function selection control signal                     --
--                                                                            --
--  Outputs:                                                                  --
--           r[15..0] - Result of the operation                               --
--                                                                            --
--  Revision History:                                                         --
--      12/5/24  Edward Speer  Initial Revision                               --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

--
-- CORDIC16 entity declaration
--

entity CORDIC16 is
    port (
        x : in  std_logic_vector(15 downto 0);  -- 16 bit Q1.14 input 1
        y : in  std_logic_vector(15 downto 0);  -- 16 bit Q1.14 input 2
        f : in  std_logic_vector(4 downto 0);   -- Function selection control
        r : out std_logic_vector(15 downto 0)   -- Result
    );
end CORDIC16;

--
-- CORDIC16 Implementation architecture
--

architecture implementation of CORDIC16 is

    --
    -- Component declaration of XYZRow
    --

    component XYZRow
        port (
            N    : in  Integer range 0 to 16;          -- Row number
            XIn  : in  std_logic_vector(21 downto 0);  -- X input buffer
            YIn  : in  std_logic_vector(21 downto 0);  -- Y input buffer
            ZIn  : in  std_logic_vector(21 downto 0);  -- Z input buffer
            Cst  : in  std_logic_vector(21 downto 0);  -- Constant val for Z sum
            di   : in  std_logic;                      -- CORDIC decision var
            m    : in  std_logic_vector(1 downto  0);  -- CORDIC coordinate mode
            XOut : out std_logic_vector(21 downto 0);  -- X buffer out
            YOut : out std_logic_vector(21 downto 0);  -- Y buffer out
            ZOut : out std_logic_vector(21 downto 0)   -- Z buffer out
        );
    end component;

    --
    -- Constants
    --
    
    -- K constant for sin/cos and sinh/cosh
    constant K     : std_logic_vector(21  downto 0) := "0000100110110111010010";
    constant hK    : std_logic_vector(21  downto 0) := "0000110110100010011100";

    -- 2^-i for i = 0 to 16
    constant delta : std_logic_vector(373 downto 0) := "0001000000000000000000" &
                                                       "0000100000000000000000" &
                                                       "0000010000000000000000" &
                                                       "0000001000000000000000" &
                                                       "0000000100000000000000" &
                                                       "0000000010000000000000" &
                                                       "0000000001000000000000" &
                                                       "0000000000100000000000" &
                                                       "0000000000010000000000" &
                                                       "0000000000001000000000" &
                                                       "0000000000000100000000" &
                                                       "0000000000000010000000" &
                                                       "0000000000000001000000" &
                                                       "0000000000000000100000" &
                                                       "0000000000000000010000" &
                                                       "0000000000000000001000" &
                                                       "0000000000000000000100";

    -- atan(2^-i) for i = 0 to 16
    constant atans : std_logic_vector(373 downto 0) := "0000110010010000111111" &
                                                       "0000011101101011000110" &
                                                       "0000001111101011011011" &
                                                       "0000000111111101010110" &
                                                       "0000000011111111101010" &
                                                       "0000000001111111111101" &
                                                       "0000000000111111111111" &
                                                       "0000000000011111111111" &
                                                       "0000000000001111111111" &
                                                       "0000000000000111111111" &
                                                       "0000000000000011111111" &
                                                       "0000000000000001111111" &
                                                       "0000000000000000111111" &
                                                       "0000000000000000011111" &
                                                       "0000000000000000001111" &
                                                       "0000000000000000000111" &
                                                       "0000000000000000000011";

    -- atanhs for i = 0 to 16
    constant htans : std_logic_vector(373 downto 0) := "0000100011001001111101" &
                                                       "0000010000010110001010" &
                                                       "0000001000000010101100" &
                                                       "0000000100000000010101" &
                                                       "0000000010000000000010" &
                                                       "0000000001000000000000" &
                                                       "0000000000100000000000" &
                                                       "0000000000010000000000" &
                                                       "0000000000001000000000" &
                                                       "0000000000000100000000" &
                                                       "0000000000000010000000" &
                                                       "0000000000000001000000" &
                                                       "0000000000000000100000" &
                                                       "0000000000000000010000" &
                                                       "0000000000000000001000" &
                                                       "0000000000000000000100" &
                                                       "0000000000000000000010";
    --
    -- Internal signals
    --

    signal m     : std_logic_vector(1   downto 0); -- CORDIC coordinate mode
    signal d     : std_logic_vector(16  downto 0); -- Decision var per row
    signal X0    : std_logic_vector(21  downto 0); -- X coord. input
    signal Y0    : std_logic_vector(21  downto 0); -- Y coord. input
    signal Z0    : std_logic_vector(21  downto 0); -- Z coord. input
    signal xOuts : std_logic_vector(373 downto 0); -- X outputs for all rows
    signal yOuts : std_logic_vector(373 downto 0); -- Y outputs for all rows
    signal zOuts : std_logic_vector(373 downto 0); -- Z outputs for all rows
    signal cIns  : std_logic_vector(373 downto 0); -- Select constant based on m

begin

    -- m is 0 for multiplication and division only
    m(1) <= f(1) or f(0);

    -- m is positive for sin/cos and negative for sinh/cosh
    m(0) <= f(0);

    -- Xin is x when m is 0, K otherwise
    with m select
        X0 <= "00" & x & "0000" when "00",
              K when "11",
              hK when others;

    -- Yin is y when dividing, 0 otherwise
    Y0 <= "00" & y & "0000" when f(3) = '1' else "0000000000000000000000";

    -- Zin is 0 when dividing, otherwise input 2
    Z0 <= "0000000000000000000000" when f(3) = '1' else "00" & y & "0000";

    -- Select which constants to use in z sum based on m value
    with m select
        cIns <= delta when "00",
                atans when "11",
                htans when others;

    -- Decision var at every row is 1 when we want to subtract, 0 for add
    d(0) <= Z0(19);
    GenD: for i in 1 to 16 generate
        d(i) <= ZOuts(393 - i * 22);
    end generate;

    -- Create port map for the first XYZ row
    XYZ1 : XYZRow port map (
        N    => 0,
        XIn  => X0,
        YIn  => Y0,
        ZIn  => Z0,
        Cst  => cIns(373 downto 352),
        di   => d(0),
        m    => m,
        XOut => xOuts(373 downto 352),
        YOut => yOuts(373 downto 352),
        ZOut => zOuts(373 downto 352)
    );

    -- Generate port maps for the remaining 16 rows
    GenXYZRows: for i in 0 to 15 generate
        XYZRowN : XYZRow port map (
            N    => i + 1,
            XIn  => xOuts(373 - i * 22 downto 352 - i * 22),
            YIn  => yOuts(373 - i * 22 downto 352 - i * 22),
            ZIn  => zOuts(373 - i * 22 downto 352 - i * 22),
            Cst  =>  cIns(351 - i * 22 downto 330 - i * 22),
            di   => d(i + 1),
            m    => m,
            XOut => xOuts(373 - (i + 1) * 22 downto 352 - (i + 1) * 22),
            YOut => yOuts(373 - (i + 1) * 22 downto 352 - (i + 1) * 22),
            ZOut => zOuts(373 - (i + 1) * 22 downto 352 - (i + 1) * 22)
        );
    end generate;

    -- Choose the output bits based on the operation
    with f(3 downto 2) select
        r <= zOuts(19 downto 4) when "11",
             yOuts(19 downto 4) when "01",
             xOuts(19 downto 4) when others;

end implementation;
