--------------------------------------------------------------------------------
--                                                                            --
--  XYCell Logic Design                                                       --
--                                                                            --
--  This is an entity declaration and architecture for a single x,y cell in   --
--  the CORDIC16 unit design. Every x. y cell is identical and fed by the     --
--  row of x, y cells above it. Each cell consists of two adder/subtractor    --
--  units fed by the x and y values from the row above. The behavior of the   --
--  cell is determined by the decision variables controlled by the CORDIC     --
--  algorithm, as well as the m parameter determined by the operation being   --
--  performed.                                                                --
--                                                                            --
--  Inputs:                                                                   --
--           XIn    - X value from the row directly above                     --
--           XShift - X value from the row above shifted by 1                 --
--           XCarry - Carry in to the X adder/subtractor from the row         --
--           YCarry - Carry in to the Y adder/subtractor from the row         --
--           YIn    - Y value from the row directly above                     --
--           YShift - Y value from the row above shifted by 1                 --
--           M      - Current CORDIC m parameter                              --
--           Di     - CORDIC decision variable for the cell's row             --
--                                                                            --
--  Outputs:                                                                  --
--           XOut   - X value for the row below                               --
--           YOut   - Y value for the row below                               --
--           XCOut  - Carry out from the X adder/subtractor                   --
--           YCOut  - Carry out from the Y adder/subtractor                   --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use     ieee.std_logic_1164.all;

--
-- XYCell entity declaration
--

entity XYCell is
    port (
        XIn    : in  std_logic;  -- X value from the row directly above
        XShift : in  std_logic;  -- X value from the row above shifted by 1
        XCarry : in  std_logic;  -- Carry in to the X adder/subtractor from row
        YCarry : in  std_logic;  -- Carry in to the Y adder/subtractor from row
        YIn    : in  std_logic;  -- Y value from the row directly above
        YShift : in  std_logic;  -- Y value from the row above shifted by 1
        XSub   : in  std_logic;  -- Subtract control signal for X AddSub1
        YSub   : in  std_logic;  -- Subtract control signal for Y AddSub1
        XOut   : out std_logic;  -- X value for the row below
        YOut   : out std_logic;  -- Y value for the row below
        XCOut  : out std_logic;  -- Carry out from the X adder/subtractor
        YCOut  : out std_logic   -- Carry out from the Y adder/subtractor
    );
end XYCell;

--
-- XYCell DataFlow architecture
--

architecture DataFlow of XYCell is

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

begin

    --
    -- Port maps for each of the XAddSub and YAddSub AddSub1 units
    --

    XAddSub: AddSub1 port map (
        A    => XIn,
        B    => YShift,
        Sub  => XSub,
        CIn  => XCarry,
        S    => XOut,
        COut => XCOut
    );

    YAddSub: AddSub1 port map (
        A    => YIn,
        B    => XShift,
        Sub  => YSub,
        CIn  => YCarry,
        S    => YOut,
        COut => YCOut
    );

end DataFlow;
