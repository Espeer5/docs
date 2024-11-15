--------------------------------------------------------------------------------
--                                                                            --
--  Cntr8ClockDiv Test Bench                                                  --
--                                                                            --
--  This is a test bench for the Cntr8ClockDiv block of the PWM Audio Player  --
--  system. The test bench thoroughly tests the entity by exercising it and   --
--  checking the timing of the output 8 kHz clock and the 8 bit counter       --
--  output. The test bench entity is called Cntr8ClockDiv_tb and it is        --
--  currently defined to test the behavioral architecture of the              --
--  Cntr8ClockDiv unit.                                                       --
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

entity Cntr8ClockDiv_tb is
end Cntr8ClockDiv_tb;

--
-- Cntr8ClockDiv_tb TB_ARCHITECTURE
--

architecture TB_ARCHITECTURE of Cntr8ClockDiv_tb is

    --
    -- Component declaration of the device under test
    --

    component Cntr8ClockDiv
        port (
            CLK      : in     std_logic;                    -- 32 MHz sys clk
            RESET    : in     std_logic;                    -- Async reset
            CLK_8kHz : buffer std_logic;                    -- 8 kHz clk out
            Cntr8    : out    std_logic_vector(7 downto 0)  -- 8 bit cnt out
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK   : std_logic := '0'; -- 32 MHz system clock
    signal RESET : std_logic := '0'; -- Asynchronous reset

    --
    -- Observed signals
    --

    signal CLK_8kHz : std_logic := '0';
    signal Cntr8    : std_logic_vector(7 downto 0) := "00000000";

    --
    -- Flag used to end simulation
    --

    signal END_SIM : BOOLEAN := FALSE;

begin

    --
    -- Device under test port map
    --

    DUT : Cntr8ClockDiv
        port map (
            CLK      => CLK,
            RESET    => RESET,
            CLK_8kHz => CLK_8kHz,
            Cntr8    => Cntr8
        );

    process
    
    variable c80 : std_logic := '0'; -- Store the 8 bit counter output

    begin        -- TEST_CLK8KHZ
        RESET <= '1';
        wait for 64000 ns;
        RESET <= '0';
        -- Test that the 8 kHz clock signal is generated correctly
        for i in 100 downto 0 loop
            c80 := CLK_8kHz;

            -- Wait until 2048 32 MHz clocks have elapsed
            wait for 64000 ns;
            -- After allowing one 8 kHz clock cycle to elapse, check that the
            -- 8 kHz clock signal has toggled
            if i < 99 then
                assert (std_match(c80, not CLK_8kHz))
                    report "8 kHz clock signal did not toggle"
                    severity ERROR;
            end if;
        end loop;

        -- End the simulation
        END_SIM <= TRUE;
        wait;

    end process; -- TEST_CLK8KHZ

    process      -- TEST_CNT8

        variable cnt : unsigned(7 downto 0) := (others => '0'); -- 8 bit counter

    begin
        wait for 1 sec;
        if END_SIM = FALSE then
            cnt := unsigned(Cntr8);
            wait for 31250 ps;
            assert (std_match(Cntr8, std_logic_vector(cnt + 1)))
                report "8 bit counter output does not match expected value"
                severity ERROR;
        else
            wait;
        end if;

    end process; -- TEST_CNT8

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

-- Configure use of Cntr8ClockDiv behavioral architecture in test
configuration TESTBENCH_FOR_CNTR8CLOCKDIV_BEHAVIORAL of Cntr8ClockDiv_tb is
    for TB_ARCHITECTURE
        for DUT : Cntr8ClockDiv
            use entity work.Cntr8ClockDiv(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_CNTR8CLOCKDIV_BEHAVIORAL;

-- Configure use of Cntr8ClockDiv implementation architecture in test
configuration TESTBENCH_FOR_CNTR8CLOCKDIV_IMPLEMENTATION of Cntr8ClockDiv_tb is
    for TB_ARCHITECTURE
        for DUT : Cntr8ClockDiv
            use entity work.Cntr8ClockDiv(implementation);
        end for;
    end for;
end TESTBENCH_FOR_CNTR8CLOCKDIV_IMPLEMENTATION;
