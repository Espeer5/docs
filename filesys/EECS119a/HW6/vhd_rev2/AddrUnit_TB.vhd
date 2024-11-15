--------------------------------------------------------------------------------
--                                                                            --
--  AddrUnit Test Bench                                                       --
--                                                                            --
--  This is a test bench for the AddrUnit block of the PWM Audio Player       --
--  system. The test bench thoroughly tests the entity by exercising it and   --
--  checking the output address and enable signals. The test bench entity is  --
--  called AddrUnit_tb and it is currently defined to test the behavioral     --
--  architecture of the AddrUnit unit.                                        --
--                                                                            --
--  Revision History:                                                         --
--      11/14/2024  Edward Speer  Initial revision                            --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

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
    -- Component declaration of the device under test
    --

    component AddrUnit
        port (
            CLK_8kHz  : in     std_logic;                    -- Sample rate clk
            RESET     : in     std_logic;                    -- Asynch reset
            enable    : buffer std_logic;                    -- enable audio out
            Btn       : in     std_logic_vector(3 downto 0); -- Button input
            AudioAddr : buffer std_logic_vector(18 downto 0) -- address output
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK_8kHz  : std_logic := '0';
    signal RESET     : std_logic := '0';
    signal Btn       : std_logic_vector(3 downto 0) := "0000";

    --
    -- Observed signals
    --

    signal AudioAddr : std_logic_vector(18 downto 0) := "0000000000000000000";
    signal enable    : std_logic;

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
        CLK_8kHz  => CLK_8kHz,
        RESET     => RESET,
        enable    => enable,
        Btn       => Btn,
        AudioAddr => AudioAddr
    );

    --
    -- Stimulus process
    --

    process
    begin
    
        -- Initialize the system with a reset
        RESET <= '1';
        wait for 126000 ns;
        RESET <= '0';

        -- Test a button press
        Btn <= "1000";
        wait for 126000 ns;
        Btn <= "0000";
        wait for 10 sec;
        assert (std_match(AudioAddr, "1001000000000000000") = TRUE)
            report "INCORRECT ADDRESS"
            severity ERROR;

        -- Test the system with a button press and then a resettling period.
        Btn <= "0100";
        wait for 126000 ns;
        assert (enable = '1')
            report "MISSED BUTTON PRESS"
            severity ERROR;
        Btn <= "0000";
        wait for 10 sec;
        assert (enable = '0')
            report "BUTTON PRESS NOT CLEARED"
            severity ERROR;
        assert (std_match(AudioAddr, "1011000000000000000") = TRUE)
            report "INCORRECT ADDRESS"
            severity ERROR;
        
        -- Try a new button press with multiple buttons
        Btn <= "0011";
        wait for 126000 ns;
        assert (enable = '1')
            report "MISSED BUTTON PRESS"
            severity ERROR;
        Btn <= "0000";
        wait for 20 sec;
        assert (enable = '0')
            report "BUTTON PRESS NOT CLEARED"
            severity ERROR;
        assert (std_match(AudioAddr, "1111100000000000000") = TRUE)
            report "INCORRECT ADDRESS"
            severity ERROR;

        -- Check address on last button
        Btn <= "0001";
        wait for 126000 ns;
        assert (enable = '1')
            report "MISSED BUTTON PRESS"
            severity ERROR;
        Btn <= "0000";
        wait for 10 sec;
        assert (enable = '0')
            report "BUTTON PRESS NOT CLEARED"
            severity ERROR;
        assert (std_match(AudioAddr, "1111111111111111111") = TRUE)
            report "INCORRECT ADDRESS"
            severity ERROR;

        -- End the simulation
        END_SIM <= TRUE;
        wait;

    end process;

    CLOCK_CLK : process
        -- This process generates an 8kHz x 50% duty cycle clock, and stops the
        -- clock when the end of simulation is reached.
        begin
            -- Generates 32 MHz clock
            if END_SIM = FALSE then
                CLK_8kHz <= '0';
                wait for 62500 ns;
            else
                wait;
            end if;
    
            if END_SIM = FALSE then
                CLK_8kHz <= '1';
                wait for 62500 ns;
            else
                wait;
            end if;
    
    end process; -- CLOCK_CLK

end TB_ARCHITECTURE;

-- Configure use of AddrUnit behavioral architecture in test
configuration TESTBENCH_FOR_ADDRUNIT_BEHAVIORAL of AddrUnit_tb is
    for TB_ARCHITECTURE
        for DUT : AddrUnit
            use entity work.AddrUnit(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_ADDRUNIT_BEHAVIORAL;

-- Configure use of AddrUnit implementation architecture in test
configuration TESTBENCH_FOR_ADDRUNIT_IMPLEMENTATION of AddrUnit_tb is
    for TB_ARCHITECTURE
        for DUT : AddrUnit
            use entity work.AddrUnit(implementation);
        end for;
    end for;
end TESTBENCH_FOR_ADDRUNIT_IMPLEMENTATION;
