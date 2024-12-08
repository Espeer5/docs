--------------------------------------------------------------------------------
--                                                                            --
--  CORDIC16 Testbench                                                        --
--                                                                            --
--  This is atestbench for the CORDIC16 entity. It will test the CORDIC16     --
--  implementation architecture to ensure it can compute all desired          --
--  functions correctly over the appropriate range of input values. The       --
--  testbench entity is called CORDIC16_TB.                                   --
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

entity CORDIC16_TB is
end    CORDIC16_TB;

--
-- CORDIC16_TB TB_architecture
--

architecture TB_architecture of CORDIC16_TB is

    --
    -- Component declaration of CORDIC16
    --

    component CORDIC16
        port (
            x : in  std_logic_vector(15 downto 0);  -- X input
            y : in  std_logic_vector(15 downto 0);  -- Y input
            f : in  std_logic_vector(4 downto 0);   -- Function selection signal
            r : out std_logic_vector(15 downto 0)   -- Result
        );
    end component;

    --
    -- Stimulus signals
    --

    signal x : std_logic_vector(15 downto 0);  -- X input
    signal y : std_logic_vector(15 downto 0);  -- Y input
    signal f : std_logic_vector(4 downto 0);   -- Function selection signal

    --
    -- Observed signals
    --

    signal r : std_logic_vector(15 downto 0);  -- Result

    --
    -- Test vectors
    --

    constant nTests : Integer := 6;
    signal   xs     : std_logic_vector(nTests * 16 - 1 downto 0);
    signal   ys     : std_logic_vector(nTests * 16 - 1 downto 0);
    signal   fs     : std_logic_vector(nTests * 5  - 1 downto 0);
    signal   rs     : std_logic_vector(nTests * 16 - 1 downto 0);

begin

    --
    -- Device under test port map
    --

    DUT : CORDIC16 port map (
        x => x,
        y => y,
        f => f,
        r => r
    );

    --
    -- Test vectors
    --
    ys <= "----------------" & -- cos(28 deg) = .882...
          "----------------" & -- sin(28 deg) = .469...
          "0010000000000000" & -- 0.5 * 0.5 = 0.25
          "0010000000000000" & -- 0.5 / 0.5 = 1.0
          "----------------" & -- cosh(28 deg) = 1.121...
          "----------------";  -- sinh(28 deg) = .508...

    xs <= "0001111101000110" & -- cos(28 deg) = .882...
          "0001111101000110" & -- sin(28 deg) = .469...
          "0010000000000000" & -- 0.5 * 0.5 = 0.25
          "0010000000000000" & -- 0.5 / 0.5 = 1.0
          "0000010110010101" & -- cosh(28 deg) = 1.121...
          "0000010110010101";  -- sinh(28 deg) = .508...

    fs <= "00001" &            -- cos(28 deg) = .882...
          "00101" &            -- sin(28 deg) = .469...
          "00100" &            -- 0.5 * 0.5 = 0.25
          "01100" &            -- 0.5 / 0.5 = 1.0
          "00010" &            -- cosh(28 deg) = 1.121...
          "00110";             -- sinh(28 deg) = .508...

    process      -- TEST_PROCESS
    begin

        -- Initialize DUT inputs
        x <= (others => '0');
        y <= (others => '0');
        f <= (others => '0');

        wait for 10 ns;

        -- Loop over test vectors and test each case
        for i in 0 to nTests - 1 loop
            x <= xs(i * 16 + 15 downto i * 16);
            y <= ys(i * 16 + 15 downto i * 16);
            f <= fs(i * 5  + 4  downto i * 5);

            wait for 10 ns;

            report std_logic'image(r(15)) & std_logic'image(r(14)) &
                   std_logic'image(r(13)) & std_logic'image(r(12)) &
                   std_logic'image(r(11)) & std_logic'image(r(10)) &
                   std_logic'image(r(9))  & std_logic'image(r(8))  &
                   std_logic'image(r(7))  & std_logic'image(r(6))  &
                   std_logic'image(r(5))  & std_logic'image(r(4))  &
                   std_logic'image(r(3))  & std_logic'image(r(2))  &
                   std_logic'image(r(1))  & std_logic'image(r(0))
                   severity note;
        end loop;

        -- End the simulation
        wait;

    end process; -- TEST_PROCESS


end TB_architecture;

configuration TESTBENCH_FOR_CORDIC16_IMPLEMENTATION of CORDIC16_TB is
    for TB_architecture
        for DUT : CORDIC16
            use entity work.CORDIC16(implementation);
        end for;
    end for;
end TESTBENCH_FOR_CORDIC16_IMPLEMENTATION;
