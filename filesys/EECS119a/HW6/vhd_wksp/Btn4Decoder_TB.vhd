--------------------------------------------------------------------------------
--                                                                            --
--  Btn4Decoder test bench                                                    --
--                                                                            --
--  This is a test bench for the Btn4Decoder button decoding module used to   --
--  accept user input on the buttons in the PWM audio player system. The      --
--  test bench thoroughly tests the entity by exercising it and checking      --
--  the filtered button outputs. The test bench entity is called              --
--  Btn4Decoder_tb and it is currently defined to test the behavioral and     --
--  implementation architecture of the Btn4Decoder entity.                    --
--                                                                            --
--  Revision History:                                                         --
--      11/12/2024  Edward Speer  Initial Revision                            --
--      11/13/2024  Edward Speer  Test implementation architecture            --
--      11/14/2024  Edward Speer  Test with address logic removed             --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Btn4Decoder_tb is
end Btn4Decoder_tb;

--
-- Btn4Decoder_tb TB_ARCHITECTURE
--

architecture TB_ARCHITECTURE of Btn4Decoder_tb is

    --
    -- Component declaration of the DUT
    --

    component Btn4Decoder
        port (
            CLK        : in     std_logic;                    -- 32 MHz sys clk
            BTN        : in     std_logic_vector(3 downto 0); -- 4 buttons in
            FilButton  : out    std_logic_vector(3 downto 0)  -- Filtered btns
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK    : std_logic;
    signal BTN    : std_logic_vector(3 downto 0) := "0000";

    --
    -- Observed signals
    --

    signal FilButton : std_logic_vector(3 downto 0);

    --
    -- Flag used to end simulation
    --

    signal END_SIM : BOOLEAN := FALSE;

begin

    --
    -- Device under test port map
    --

    DUT : Btn4Decoder
        port map (
            CLK       => CLK,
            BTN       => BTN,
            FilButton => FilButton
        );

    process      -- STIMULUS_PROCESS

    begin

        wait for 500000 ns;

        -- Ensure that the system initialization has worked
        assert (FilButton = "0000")
            report "INITIALIZATION FAILED"
            severity ERROR;

        -- Try every combination of button presses and ensure the filtered btns
        -- out are correct and as expected
        BTN <= "0000";
        wait for 1000 ns;
        assert (FilButton = "0000")
            report "BTN = 0000 FAILED"
            severity ERROR;

        BTN <= "1000";
        wait for 100 ns;
        assert (FilButton = "1000")
            report "BTN = 1000 FAILED"
            severity ERROR;

        BTN <= "0100";
        wait for 100 ns;
        assert (FilButton = "0100")
            report "BTN = 0100 FAILED"
            severity ERROR;

        BTN <= "0010";
        wait for 100 ns;
        assert (FilButton = "0010")
            report "BTN = 0010 FAILED"
            severity ERROR;

        BTN <= "0001";
        wait for 100 ns;
        assert (FilButton = "0001")
            report "BTN = 0001 FAILED"
            severity ERROR;

        BTN <= "1100";
        wait for 100 ns;
        assert (FilButton = "1000")
            report "BTN = 1100 FAILED"
            severity ERROR;

        BTN <= "1010";
        wait for 100 ns;
        assert (FilButton = "1000")
            report "BTN = 1010 FAILED"
            severity ERROR;

        BTN <= "1001";
        wait for 100 ns;
        assert (FilButton = "1000")
            report "BTN = 1001 FAILED"
            severity ERROR;

        BTN <= "0110";
        wait for 100 ns;
        assert (FilButton = "0100")
            report "BTN = 0110 FAILED"
            severity ERROR;

        BTN <= "0101";
        wait for 100 ns;
        assert (FilButton = "0100")
            report "BTN = 0101 FAILED"
            severity ERROR;

        BTN <= "0011";
        wait for 100 ns;
        assert (FilButton = "0010")
            report "BTN = 0011 FAILED"
            severity ERROR;

        BTN <= "1110";
        wait for 100 ns;
        assert (FilButton = "1000")
            report "BTN = 1110 FAILED"
            severity ERROR;

        BTN <= "1101";
        wait for 100 ns;
        assert (FilButton = "1000")
            report "BTN = 1101 FAILED"
            severity ERROR;

        BTN <= "1011";
        wait for 100 ns;
        assert (FilButton = "1000")
            report "BTN = 1011 FAILED"
            severity ERROR;

        BTN <= "0111";
        wait for 100 ns;
        assert (FilButton = "0100")
            report "BTN = 0111 FAILED"
            severity ERROR;

        -- End simulation
        END_SIM <= TRUE;
        wait;

    end process; -- STIMULUS_PROCESS

    CLOCK_CLK : process

    -- This process generates a 32 MHz x 50% duty cycle clock, and stops the
    -- clock when the end of simulation is reached.
    begin
        -- Generates 32 MHz clock
        if END_SIM = FALSE then
            CLK <= '0';
            wait for 15625 ps;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            CLK <= '1';
            wait for 15625 ps;
        else
            wait;
        end if;

    end process; -- CLOCK_CLK

end TB_ARCHITECTURE;

-- Configure use of Btn4Decoder implementation architecture
configuration TESTBENCH_FOR_BTN4DECODER_IMPLEMENTATION of Btn4Decoder_tb is
    for TB_ARCHITECTURE
        for DUT : Btn4Decoder
            use entity work.Btn4Decoder(implementation);
        end for;
    end for;
end TESTBENCH_FOR_BTN4DECODER_IMPLEMENTATION;
