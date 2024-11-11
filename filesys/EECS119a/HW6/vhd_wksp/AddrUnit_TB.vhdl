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
            LOAD      : in     std_logic;                    -- Load AddrIn 
            AddrIn    : in     std_logic_vector(18 downto 0);-- 19 bit addr in
            AudioAddr : buffer std_logic_vector(18 downto 0);-- 19 bit addr out
            AddrValid : buffer std_logic;                    -- Legal addr?
            AddrStop  : in     std_logic_vector(18 downto 0) -- Max track addr
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK       : std_logic;
    signal LOAD      : std_logic;
    signal AddrValid : std_logic;
    signal AddrIn    : std_logic_vector(18 downto 0);
    signal AddrStop  : std_logic_vector(18 downto 0);

    --
    -- Observed signals
    --

    signal AudioAddr : std_logic_vector(18 downto 0);

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
            LOAD      => LOAD,
            AddrIn    => AddrIn,
            AddrValid => AddrValid,
            AddrStop  => AddrStop,
            AudioAddr => AudioAddr
        );

    process -- STIMULUS_PROCESS

        variable UnsignedAddr : unsigned(18 downto 0); -- Unsigned of AudioAddr
        constant MAX_19BIT    : integer := 524287;     -- Max 19 bit address

    begin

        -- Initialize the AddrUnit DUT by loading a value and a top value
        LOAD     <= '1';
        AddrIn   <= "1111111111111111110";
        AddrStop <= "0000000000000000001";

        -- Wait for load to take effect and check it
        wait for 250000 ns;
        assert(AudioAddr = "1111111111111111110")
            report "INITIALIZATION FAILED"
            severity ERROR;

        -- Release the load signal and store unsigned val of addr
        LOAD <= '0';
        UnsignedAddr := unsigned(AudioAddr);
        
        -- Count through enough values to loop over MAX_19BIT and check looping
        -- and that addr has become invalid
        for i in 100 downto 0 loop
            -- Wait until clock cycle has passed
            wait for 125000 ns;

            -- Check that the value has been incremented correctly
            assert(unsigned(AudioAddr) = ((UnsignedAddr + 1) rem
                                                               (MAX_19BIT + 1)))
                report "INCREMENT FAILED"
                severity ERROR;

            -- Store value of AudioAddr
            UnsignedAddr := unsigned(AudioAddr);
        end loop;

        assert (AddrValid = '0')
            report "CHECK ADDR VALID FAILED"
            severity ERROR;

        -- Shut off the clock and wait for the simulation to end
        END_SIM <= TRUE;
        wait;

    end process;

    CLOCK_CLK : process

    -- This process generates a 32 MHz x 50% duty cycle clock, and stops the
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

-- Configure AddrUnit architecture used
configuration TESTBENCH_FOR_AddrUnit of AddrUnit_tb is
    for TB_ARCHITECTURE
        for DUT : AddrUnit
            use entity work.AddrUnit(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_AddrUnit;
