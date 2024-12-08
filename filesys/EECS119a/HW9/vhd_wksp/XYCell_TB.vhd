--------------------------------------------------------------------------------
--                                                                            --
--  XYCell Test bench                                                         --
--                                                                            --
--  This a test bench for the XYCell entity of the CORDIC16 unit design.      --
--  It will test the XYCell DataFlow architecture for an extensive range of   --
--  input values and verify that the outputs are correct. The testbench       --
--  entity is called XYCell_TB.                                               --
--                                                                            --
--  Revision History:                                                         --
--      12/5/2024  Edward Speer  Initial Revision                             --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use     ieee.std_logic_1164.all;

entity XYCell_TB is
end    XYCell_TB;

--
-- XYCell_TB TB_architecture
--

architecture TB_architecture of XYCell_TB is

    --
    -- Component declaration of XYCell
    --

    component XYCell
        port (
            XIn    : in  std_logic;                    -- x value from row above
            XShift : in  std_logic;                    -- Shifted x from above
            XCarry : in  std_logic;                    -- Carry in to the x A/S
            YCarry : in  std_logic;                    -- Carry in to the y A/S
            YIn    : in  std_logic;                    -- y value from row above
            YShift : in  std_logic;                    -- Shifted y from above
            Di     : in  std_logic;                    -- CORDIC decision var 
            XOut   : out std_logic;                    -- X value out
            YOut   : out std_logic;                    -- Y value out
            XCOut  : out std_logic;                    -- Carry out from x A/S
            YCOut  : out std_logic;                    -- Carry out from y A/S
            M      : in  std_logic_vector(1 downto 0)  -- CORDIC m var
        );
    end component;

    --
    -- Stimulus signals
    --

    signal XIn    : std_logic;  -- X value from the row directly above
    signal XShift : std_logic;  -- X value from the row above shifted by 1
    signal XCarry : std_logic;  -- Carry in to the X adder/subtractor
    signal YCarry : std_logic;  -- Carry in to the Y adder/subtractor
    signal YIn    : std_logic;  -- Y value from the row directly above
    signal YShift : std_logic;  -- Y value from the row above shifted by 1
    signal Di     : std_logic;  -- CORDIC decision variable

    signal M      : std_logic_vector(1 downto 0); -- Current CORDIC m var

    --
    -- Observed signals
    --

    signal XOut   : std_logic;  -- X value for the row below
    signal YOut   : std_logic;  -- Y value for the row below
    signal XCOut  : std_logic;  -- Carry out from the X adder/subtractor
    signal YCOut  : std_logic;  -- Carry out from the Y adder/subtractor

    --
    -- Test vectors
    --

    constant nTests : Integer := 4;
    signal XIns     : std_logic_vector(nTests - 1     downto 0);
    signal XShifts  : std_logic_vector(nTests - 1     downto 0);
    signal XCarrys  : std_logic_vector(nTests - 1     downto 0);
    signal YCarrys  : std_logic_vector(nTests - 1     downto 0);
    signal YIns     : std_logic_vector(nTests - 1     downto 0);
    signal YShifts  : std_logic_vector(nTests - 1     downto 0);
    signal Ms       : std_logic_vector(2 * nTests - 1 downto 0);
    signal Dis      : std_logic_vector(nTests - 1     downto 0);
    signal XOuts    : std_logic_vector(nTests - 1     downto 0);
    signal YOuts    : std_logic_vector(nTests - 1     downto 0);
    signal XCOuts   : std_logic_vector(nTests - 1     downto 0);
    signal YCOuts   : std_logic_vector(nTests - 1     downto 0);

begin

    -- Device under test port map
    DUT : XYCell port map (
        XIn    => XIn,    -- X value from the row directly above
        XShift => XShift, -- X value from the row above shifted by 1
        XCarry => XCarry, -- Carry in to the X adder/subtractor
        YCarry => YCarry, -- Carry in to the Y adder/subtractor
        YIn    => YIn,    -- Y value from the row directly above
        YShift => YShift, -- Y value from the row above shifted by 1
        M      => M,      -- Current CORDIC m parameter
        Di     => Di,     -- CORDIC decision variable
        XOut   => XOut,   -- X value for the row below
        YOut   => YOut,   -- Y value for the row below
        XCOut  => XCOut,  -- Carry out from the X adder/subtractor
        YCOut  => YCOut   -- Carry out from the Y adder/subtractor
    );

    -- Test vectors
    XIns    <= '1' &
               '1' &
               '0' &
               '0';

    YIns    <= '1' &
               '1' &
               '0' &
               '1';

    XShifts <= '1' &
               '1' &
               '1' &
               '1';

    YShifts <= '1' &
               '1' &
               '1' &
               '1';

    XCarrys <= '1' &
               '1' &
               '0' &
               '1';

    YCarrys <= '0' &
               '0' &
               '1' &
               '1';

    Ms      <= "10" &
               "11" &
               "11" &
               "10";

    Dis     <= '0' &
               '0' &
               '1' &
               '1';

    XOuts   <= '1' &
               '0' &
               '1' &
               '1';

    YOuts   <= '0' &
               '0' &
               '1' &
               '0';

    XCOuts  <= '1' &
               '1' &
               '0' &
               '0';

    YCOuts  <= '1' &
               '1' &
               '0' &
               '1';

    process     -- TEST_PROCESS
    begin

        -- Initialize all of the inputs to the DUT
        XIn    <= '0';
        XShift <= '0';
        XCarry <= '0';
        YCarry <= '0';
        YIn    <= '0';
        YShift <= '0';
        M      <= "00";
        Di     <= '0';

        wait for 10 ns;

        -- Having already tested the AddSub1 module, we can assume that the
        -- adder/subtractor will behave as expected given the correct inputs.
        -- We therefore need to verify that inputs to the XYCell module are
        -- correct and that the outputs are as expected.

        for i in 0 to nTests - 1 loop

            XIn    <= XIns(i);
            XShift <= XShifts(i);
            XCarry <= XCarrys(i);
            YCarry <= YCarrys(i);
            YIn    <= YIns(i);
            YShift <= YShifts(i);
            M      <= Ms(2 * i + 1 downto 2 * i);
            Di     <= Dis(i);

            wait for 10 ns;

            assert (XOut = XOuts(i) and YOut = YOuts(i) and XCOut = XCOuts(i) 
                    and YCOut = YCOuts(i))
                report "Test " & integer'image(i) & " failed" severity ERROR;

        end loop;

        -- We're done, so stop the simulation
        wait;

    end process; -- TEST_PROCESS

end TB_architecture;

configuration TESTBENCH_FOR_XYCELL_DATAFLOW of XYCell_TB is
    for TB_architecture
        for DUT : XYCell
            use entity work.XYCell(DataFlow);
        end for;
    end for;
end TESTBENCH_FOR_XYCELL_DATAFLOW;
