--------------------------------------------------------------------------------
--                                                                            --
--  XYZRow Logic Design                                                       --
--                                                                            --
--  This is an entity declaration and architecture for a single row of x, y   --
--  and z cells in the CORDIC16 unit design. Every x, y, z row is identical   --
--  and fed by the row of x, y, z cells above it. Each cell consists of two   --
--  adder/subtractor units fed by the x and y values from the row above for   --
--  x and y coordinates, and a third adder/subtractor unit which sums z with  --
--  a constant value. Each row consists of 20 cells and ripples the carry out --
--  along the row for each coordinate from LSB to MSB.                        --
--                                                                            --
--  Inputs:                                                                   --
--           XIn[19..0]  - X buffer from row directly above                   --
--           YIn[19..0]  - Y buffer from row directly above                   --
--           ZIn[19..0]  - Z buffer from row directly above                   --
--           Cst[19..0]  - Constant value for Z summation                     --
--           di          - CORDIC decision variable for the row               --
--           m           - CORDIC coordinate mode                             --
--                                                                            --
--  Outputs:                                                                  --
--           XOut[19..0] - X buffer for row below                             --
--           YOut[19..0] - Y buffer for row below                             --
--           ZOut[19..0] - Z buffer for row below                             --
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
-- XYZRow entity declaration
--

entity XYZRow is
    port (
        N      : in  Integer   range 0 to 16;      -- Row number
        XIn  : in  std_logic_vector(21 downto 0);  -- X input buffer
        YIn  : in  std_logic_vector(21 downto 0);  -- Y input buffer
        ZIn  : in  std_logic_vector(21 downto 0);  -- Z input buffer
        di   : in  std_logic;                      -- CORDIC decision variable
        m    : in  std_logic_vector(1  downto 0);  -- CORDIC coordinate mode
        XOut : out std_logic_vector(21 downto 0);  -- X buffer out
        YOut : out std_logic_vector(21 downto 0);  -- Y buffer out
        ZOut : out std_logic_vector(21 downto 0)   -- Z buffer out
    );
end XYZRow;

--
-- XYZRow DataFlow architecture
--

architecture DataFlow of XYZRow is
    
    --
    -- Component declaration of XYCell
    --

    component XYCell
        port (
            XIn    : in  std_logic;                    -- x value from above
            XShift : in  std_logic;                    -- Shifted x from above
            XCarry : in  std_logic;                    -- Carry in to x A/S
            YCarry : in  std_logic;                    -- Carry in to y A/S
            YIn    : in  std_logic;                    -- Y value from above
            YShift : in  std_logic;                    -- Shifted y from above
            XOut   : out std_logic;                    -- X value out
            YOut   : out std_logic;                    -- Y value out
            XCOut  : out std_logic;                    -- Carry out from x A/S
            YCOut  : out std_logic;                    -- Carry out from y A/S
            XSub   : in  std_logic;                    -- Subtract control signal for X AddSub1
            YSub   : in  std_logic                     -- Subtract control signal for Y AddSub1
        );
    end component;

    --
    -- Component declaration of AddSub1
    --
    component AddSub1
        port (
            A    : in  std_logic;  -- First input bit
            B    : in  std_logic;  -- Second input bit
            Sub  : in  std_logic;  -- Subtract control signal
            CIn  : in  std_logic;  -- Carry in bit
            S    : out std_logic;  -- Output bit
            COut : out std_logic   -- Carry out bit
        );
    end component;

    --
    -- Constants for z sum
    --

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
    -- Repeat iterations 4 and 13 to ensure convergence
    -- Leave a placeholder for iter 0 to keep indexing consistent
    constant htans : std_logic_vector(373 downto 0) := "0000000000000000000000" &
                                                       "0000100011001001111101" &
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
                                                       "0000000000000000000100";

    type seq is array(16 downto 0) of integer range 0 to 16;
    constant sSeq : seq := (16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);
    constant hSeq : seq := (15, 14, 13, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 1);
    
    --
    -- Internal signals
    --

    signal XShift : std_logic_vector(21 downto 0);  -- X shift buffer
    signal YShift : std_logic_vector(21 downto 0);  -- Y shift buffer
    signal XCarry : std_logic_vector(21 downto 0);  -- X carry buffer
    signal YCarry : std_logic_vector(21 downto 0);  -- Y carry buffer
    signal ZCarry : std_logic_vector(21 downto 0);  -- Z carry buffer
    signal XSub   : std_logic;                      -- Subtract control for x
    signal ZSub   : std_logic;                      -- Subtract control for z
    signal curSeq : seq;                            -- Iter count sequence
    signal Cst    : std_logic_vector(21 downto 0);  -- Constant for z sum

begin

    ZSub   <= not di;

    -- Use modified iteration sequence for hyperbolic convergence
    curSeq <= hSeq when m = "10" else sSeq;

    -- Compute whether or not we are subtracting on x
    XSub <= m(0) xor di;

    XShift <= std_logic_vector(unsigned(XIn) srl curSeq(N));

    -- yShift is zero if m is zero (m(1) = 0)
    YShift <= std_logic_vector(unsigned(YIn) srl curSeq(N)) when m(1) = '1'
                                                           else (others => '0');

    -- Choose the constant for the z sum based on the operation
    Cst <= delta(373 - curSeq(N) * 22 downto 352 - curSeq(N) * 22) when m = "00" else
           atans(373 - curSeq(N) * 22 downto 352 - curSeq(N) * 22) when m = "11" else
           htans(373 - curSeq(N) * 22 downto 352 - curSeq(N) * 22);

    -- Port map for the first XYCell (LSB) in the row
    XYCell0: XYCell port map (
        XIn    => XIn(0),
        XShift => XShift(0),
        XCarry => XSub,
        YCarry => di,
        YIn    => YIn(0),
        YShift => YShift(0),
        XSub   => XSub,
        YSub   => di,
        XOut   => XOut(0),
        YOut   => YOut(0),
        XCOut  => XCarry(0),
        YCOut  => YCarry(0)
    );

    -- Generate the port mappings for the remaining XYCells in the row
    XYCellGen: for i in 1 to 21 generate
        XYCellN: XYCell port map (
            XIn    => XIn(i),
            XShift => XShift(i),
            XCarry => XCarry(i-1),
            YCarry => YCarry(i-1),
            YIn    => YIn(i),
            YShift => YShift(i),
            XSub   => XSub,
            YSub   => di,
            XOut   => XOut(i),
            YOut   => YOut(i),
            XCOut  => XCarry(i),
            YCOut  => YCarry(i)
        );
    end generate;

    -- Port map for the first Z cell in the row
    AddSub1Z0: AddSub1 port map (
        A    => ZIn(0),
        B    => Cst(0),
        Sub  => ZSub,
        CIn  => ZSub,
        S    => ZOut(0),
        COut => ZCarry(0)
    );

    -- Generate the port mappings for the remaining Z cells in the row
    AddSub1ZGen: for i in 1 to 21 generate
        AddSub1ZN: AddSub1 port map (
            A    => ZIn(i),
            B    => Cst(i),
            Sub  => ZSub,
            CIn  => ZCarry(i-1),
            S    => ZOut(i),
            COut => ZCarry(i)
        );
    end generate;

end DataFlow;
