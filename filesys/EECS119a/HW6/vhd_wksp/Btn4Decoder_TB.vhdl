--------------------------------------------------------------------------------
--                                                                            --
--  Btn4Decoder test bench                                                    --
--                                                                            --
--  This is a test bench for the Btn4Decoder button decoding module used to   --
--  accept user input on the buttons in the PWM audio player system. The      --
--  test bench  thoroughly tests the entity by exercising it and checking     --
--  the timing of the output clocks. The test bench entity is called          --
--  Btn4Decoder_tb and it is currently defined to test the behavioral         --
--  architecture of the Btn4Decoder entity.                                   --
--                                                                            --
--  Revision History:                                                         --
--      11/13/2024  Edward Speer  Initial Revision                            --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;

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
            enable     : in     std_logic;                    -- active low en
            LOAD       : buffer std_logic;                    -- addr load
            Sample0    : out    std_logic_vector(18 downto 0);-- Low sample addr
            SampleEnd  : out    std_logic_vector(18 downto 0) -- Hi sample addr
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK    : std_logic;
    signal enable : std_logic;
    signal BTN    : std_logic_vector(3 downto 0);

    --
    -- Observed signals
    --

    signal LOAD      : std_logic;
    signal Sample0   : std_logic_vector(18 downto 0);
    signal SampleEnd : std_logic_vector(18 downto 0);

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
            enable    => enable,
            LOAD      => LOAD,
            Sample0   => Sample0,
            SampleEnd => SampleEnd
        );

    process      -- STIMULUS_PROCESS

    begin

        -- Initialize all button inputs low and unit disabled
        enable <= '1';
        BTN    <= "0000";
        wait for 1000 ns;

        -- Wait for a bit and make sure the output hasn't changed
        wait for 1000 ns;
        assert (LOAD = '0')
            report "FAILED INITIALIZATION"
            severity ERROR;

        -- Toggle enable and ensure the system still holds correctly
        enable <= '0';
        wait for 1000 ns;
        assert (LOAD = '0')
            report "SPURIOUS LOAD SIGNAL"
            severity ERROR;

        -- Now, test the system response to a button
        BTN <= "1000";
        wait for 1000 ns;
        BTN <= "0000";
        wait for 50 ns;
        assert (LOAD = '1')
            report "MISSED BUTTON PRESS"
            severity ERROR;
        assert (Sample0 = "1000000000000000000")
            report "FAILED STARTING ADDR"
            severity ERROR;
        assert (SampleEnd <= "1001000000000000000")
            report "FAILED FINAL ADDR"
            severity ERROR;
        
        -- Ensure that once enable goes high, LOAD goes low
        enable <= '1';
        wait for 1000 ns;
        assert (LOAD = '0')
            report "FAILED TO RESET LOAD"
            severity ERROR;

        -- Shut off clock and wait for simulation to end
        END_SIM <= TRUE;
        wait;

    end process; -- STIMULUS_PROCESS

    CLOCK_CLK : process

    -- This process generates a 32 MHz x 50% duty cycle clock, and stops the
    -- clock when the end of simulation is reached.
    begin
        -- Generates 8 kHz clock
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

-- Configure Btn4Decoder architecture used
configuration TESTBENCH_FOR_BTN4DECODER of Btn4Decoder_tb is
    for TB_ARCHITECTURE
        for DUT : Btn4Decoder
            use entity work.Btn4Decoder(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_BTN4DECODER;
