--------------------------------------------------------------------------------
--                                                                            --
--  M32ToK8ClockDiv test bench                                                --
--                                                                            --
--  This is a test bench for the M32ToK8ClockDiv clock divider entity. The    --
--  test bench thouroughly tests the entity by exercising it and checking     --
--  the timing of the output clocks. The test bench entity is called          --
--  M32ToK8ClockDiv_tb and it is currently defined to test the                --
--  implementation architecture of the M32ToK8ClockDiv entity.                --
--                                                                            --
--  Revision History:                                                         --
--      11/10/2024  Edward Speer  Initial Revision                            --
--      11/11/2024  Edward Speer  Assume 4096 clocks per period               --
--      11/12/2024  Edward Speer  Fixup configuration                         --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity M32ToK8ClockDiv_tb is
end M32ToK8ClockDiv_tb;

--
-- M32ToK8ClockDiv TB_ARCHITECTURE
--

architecture TB_ARCHITECTURE of M32ToK8ClockDiv_tb is

    --
    -- Component declaration of the DUT 
    --

    component M32ToK8ClockDiv
        port (
            CLK          : in     std_logic; -- 32 MHz input clock
            CLK_8kHz     : buffer std_logic  -- 8 kHz output clock
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK   : std_logic := '0';

    --
    -- Observed signals
    --

    signal CLK_8kHz : std_logic := '0';

    --
    -- Flag used to end simulation
    --

    signal END_SIM : BOOLEAN := FALSE;

begin

    --
    -- Device under test port map
    --

    DUT : M32ToK8ClockDiv
        port map (
            CLK          => CLK,
            CLK_8kHz     => CLK_8kHz
        );

    process      -- STIMULUS_PROCESS

        variable c80 : std_logic; -- DUT output value holder

    begin

        -- Test clock toggles with appropriate timing
        for i in 100 downto 0 loop

            -- Load the value of the output clock from the DUT
            c80 := CLK_8kHz;

            -- Wait for next clock value change
            -- Note that assuming 4096 clocks per period offsets period slightly
            wait for 64000 ns;

            -- check clock has been toggled starting second time through loop
            -- to allow for the first loop to get the correct value loaded into
            -- c80
            if i < 99 then
                assert (std_match(CLK_8kHz, not c80) = TRUE)
                    report "8 KHZ CLOCK FAILED TO TOGGLE"
                    severity ERROR;
            end if;

        end loop;

        -- Shut off the clock and wait for simulation to end
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

-- Configure use of M32ToK8ClockDiv behavioral architecture in test
configuration TESTBENCH_FOR_M32ToK8ClockDiv_BEHAVIORAL of M32ToK8ClockDiv_tb is
    for TB_ARCHITECTURE
        for DUT : M32ToK8ClockDiv
            use entity work.M32ToK8ClockDiv(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_M32ToK8ClockDiv_BEHAVIORAL;

-- Configure use of M32ToK8ClockDiv implementation architecture in test
configuration TESTBENCH_FOR_M32ToK8ClockDiv_IMPLEMENTATION of M32ToK8ClockDiv_tb
                                                                              is
    for TB_ARCHITECTURE
        for DUT : M32ToK8ClockDiv
            use entity work.M32ToK8ClockDiv(implementation);
        end for;
    end for;
end TESTBENCH_FOR_M32ToK8ClockDiv_IMPLEMENTATION;
