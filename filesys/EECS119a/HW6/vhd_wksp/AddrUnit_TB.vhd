--------------------------------------------------------------------------------
--                                                                            --
--  AddrUnit test bench                                                       --
--                                                                            --
--  This is a test bench for the AddrUnit 19 bit address incrementer unit.    --
--  The test bench thoroughly tests the entity by exercising it and checking  --
--  the output data addresses produced. The test bench entity is called       --
--  AddrUnit_tb and it is currently defined to test the behavioral            --
--  architecture of the AddrUnit entity.                                      --
--                                                                            --
--  Revision History:                                                         --
--      11/10/2024  Edward Speer  Initial Revision                            --
--      11/11/2024  Edward Speer  Test clock to 8kHz                          --
--      11/12/2024  Edward Speer  Test implementation architecture            --
--      11/13/2024  Edward Speer  include button => address logic             --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AddrUnit_tb is
end AddrUnit_tb;

--
-- AddrUnit_tb TB_ARCHITECTURE
--

architecture TB_ARCHITECTURE of AddrUnit_tb is

    --
    -- Component declaration of the DUT
    --

    component AddrUnit
        port (
            CLK       : in     std_logic;                    -- 8 kHz clock
            RESET     : in     std_logic;                    -- Reset AddrUnit
            FilButton : in     std_logic_vector(3 downto 0); -- 4 buttons in
            AudioAddr : buffer std_logic_vector(18 downto 0);-- 19 bit addr out
            AddrValid : buffer std_logic                     -- Legal addr?
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK       : std_logic;
    signal RESET     : std_logic;
    signal FilButton : std_logic_vector(3 downto 0) := "0000";


    --
    -- Observed signals
    --

    signal AudioAddr : std_logic_vector(18 downto 0);
    signal AddrValid : std_logic;

    --
    -- Flag used to end simulation
    --

    signal END_SIM : BOOLEAN := FALSE;

begin

    --
    -- Device under test port map
    --

    DUT : AddrUnit 
        port map (
            CLK       => CLK,
            RESET     => RESET,
            FilButton => FilButton,
            AddrValid => AddrValid,
            AudioAddr => AudioAddr
        );

    process -- STIMULUS_PROCESS
    begin

        -- Reset the AddrUnit
        RESET <= '1';
        wait for 100 ns;
        RESET <= '0';

        -- Make sure that the address is initially invalid so the system won't
        -- start playing audio until a button press is detected
        wait for 100 ms;
        assert (AddrValid = '0')
            report "AddrValid is not 0 at start of simulation"
            severity ERROR;

        -- Now, input a button press to start the audio player
        FilButton <= "1000";
        wait for 300000 ns;
        assert (AddrValid = '1')
            report "AddrValid is not 1 after button press"
            severity ERROR;
        FilButton <= "0000";

        -- Wait until the end of the track is reached and ensure that the
        -- address becomes invalid again.
        wait for 5 sec;
        assert (AddrValid = '0')
            report "AddrValid is not 0 at end of track"
            severity ERROR;

        -- Ensure that the output address stopped at the expected location
        assert (AudioAddr = "1001000000000000000")
            report "AudioAddr did not stop at expected location"
            severity ERROR;

        -- Ensure that each button signal stops at the expected location
        FilButton <= "0100";
        wait for 1 sec;
        assert (AddrValid = '1')
            report "AddrValid is not 1 after button press"
            severity ERROR;
        FilButton <= "0000";
        wait for 9 sec;
        assert (AddrValid = '0')
            report "AddrValid is not 0 at end of track"
            severity ERROR;
        assert (AudioAddr = "1011000000000000000")
            report "AudioAddr did not stop at expected location"
            severity ERROR;

        FilButton <= "0010";
        wait for 1 sec;
        assert (AddrValid = '1')
            report "AddrValid is not 1 after button press"
            severity ERROR;
        FilButton <= "0000";
        wait for 19 sec;
        assert (AddrValid = '0')
            report "AddrValid is not 0 at end of track"
            severity ERROR;
        assert (AudioAddr = "1111100000000000000")
            report "AudioAddr did not stop at expected location"
            severity ERROR;

        FilButton <= "0001";
        wait for 1 sec;
        assert (AddrValid = '1')
            report "AddrValid is not 1 after button press"
            severity ERROR;
        FilButton <= "0000";
        wait for 3 sec;
        assert (AddrValid = '0')
            report "AddrValid is not 0 at end of track"
            severity ERROR;
        assert (AudioAddr = "1111111111111111111")
            report "AudioAddr did not stop at expected location"
            severity ERROR;

        -- Shut off the clock and wait for the simulation to end
        END_SIM <= TRUE;
        wait;

    end process;

    CLOCK_CLK : process

    -- This process generates an 8 MHz x 50% duty cycle clock, and stops the
    -- clock when the end of simulation is reached.
    begin
        -- Generates 8 kHz clock
        if END_SIM = FALSE then
            CLK <= '0';
            wait for 62500 ns;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            CLK <= '1';
            wait for 62500 ns;
        else
            wait;
        end if;

    end process; -- CLOCK_CLK


end TB_ARCHITECTURE;

-- Configure use of AddrUnit behavioral architecture
configuration TESTBENCH_FOR_AddrUnit_BEHAVIORAL of AddrUnit_tb is
    for TB_ARCHITECTURE
        for DUT : AddrUnit
            use entity work.AddrUnit(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_AddrUnit_BEHAVIORAL;

-- Configure use of AddrUnit implementation architecture
configuration TESTBENCH_FOR_AddrUnit_IMPLEMENTATION of AddrUnit_tb is
    for TB_ARCHITECTURE
        for DUT : AddrUnit
            use entity work.AddrUnit(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_AddrUnit_IMPLEMENTATION;
