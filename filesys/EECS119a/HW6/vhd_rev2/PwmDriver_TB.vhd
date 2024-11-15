--------------------------------------------------------------------------------
--                                                                            --
--  PwmDriver Test Bench                                                      --
--                                                                            --
--  This is a test bench for the PwmDriver block of the PWM Audio Player      --
--  system. The test bench thoroughly tests the entity by exercising it and   --
--  checking the output PWM produced. The test bench entity is called         --
--  PwmDriver_tb and it is currently defined to test the behavioral           --
--  architecture of the PwmDriver unit.                                       --
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

entity PwmDriver_tb is
end PwmDriver_tb;

--
-- PwmDriver_tb TB_ARCHITECTURE
--

architecture TB_ARCHITECTURE of PwmDriver_tb is

    --
    -- Component declaration of the device under test
    --

    component PwmDriver
        port (
            CLK_8kHz    : in  std_logic;                    -- 8 kHz sample clk
            RESET       : in  std_logic;                    -- Reset PwmDriver
            enable      : in  std_logic;                    -- enable pwm output
            AudioData   : in  std_logic_vector(7 downto 0); -- 8 bit sample
            Cntr8       : in  std_logic_vector(7 downto 0); -- 8 bit cntr input
            AudioPWMOut : out std_logic                     -- PWM output
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK_8kHz  : std_logic := '0'; -- 8 kHz sample clock
    signal RESET     : std_logic := '0'; -- Reset signal
    signal enable    : std_logic := '1'; -- enable audio output
    signal AudioData : std_logic_vector(7 downto 0) := "00000000";
    signal Cntr8     : std_logic_vector(7 downto 0) := "00000000";

    --
    -- Observed signals
    --

    signal AudioPWMOut : std_logic := '0';

    --
    -- Flag used to end simulation
    --

    signal END_SIM : BOOLEAN := FALSE;

begin

    -- Device under test port map
    DUT : PwmDriver port map (
        CLK_8kHz    => CLK_8kHz,
        RESET       => RESET,
        enable      => enable,
        AudioData   => AudioData,
        Cntr8       => Cntr8,
        AudioPWMOut => AudioPWMOut
    );

    -- Stimulus process
    process      -- STIMULUS_PROCESS
    begin

        -- First, reset the unit
        RESET <= '1';

        -- Wait for a clock cycle to allow the reset to take effect
        wait for 126000 ns;
        RESET <= '0';

        -- Simply verify the PWM output is correct based on the AudioData and
        -- Cntr8 inputs
        AudioData <= "00000000"; -- 0
        Cntr8     <= "00000001"; -- 0
        wait for 126000 ns;
        assert AudioPWMOut = '0'
            report "PWM HIGH WHEN CNTR > DATA"
            severity ERROR;

        AudioData <= "00000001"; -- 1
        Cntr8     <= "00000000"; -- 0
        wait for 126000 ns;
        assert AudioPWMOut = '1'
            report "PWM LOW WHEN CNTR < DATA"
            severity ERROR;

        -- Ensure AudioData latched only on the 8 kHz clock
        AudioData <= "10000000"; -- 0
        Cntr8     <= "11000000"; -- 0
        assert AudioPWMOut = '1'
            report "AudioData latched on wrong edge"
            severity ERROR;
        wait for 126000 ns;
        assert AudioPWMOut = '0'
            report "PWM HIGH WHEN CNTR > DATA"
            severity ERROR;

        -- Ensure that setting the enable line low disables the PWM output
        enable <= '0';
        AudioData <= "10000000"; -- 0
        Cntr8     <= "00000001"; -- 0
        wait for 126000 ns;
        assert AudioPWMOut = '0'
            report "PWM HIGH WHEN ENABLE LOW"
            severity ERROR;
        wait for 126000 ns;
        assert AudioPWMOut = '0'
            report "PWM HIGH WHEN ENABLE LOW"
            severity ERROR;

        enable <= '1';
        wait for 126000 ns;
        assert AudioPWMOut = '1'
            report "PWM LOW WHEN CNTR < DATA"
            severity ERROR;

        -- End the simulation
        END_SIM <= TRUE;
        wait;

    end process; -- STIMULUS_PROCESS

    CLOCK_CLK : process
        -- This process generates an 8 kHz x 50% duty cycle clock, and stops the
        -- clock when the end of simulation is reached.
        begin
            -- Generates 8 kHz clock
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

-- Configure use of PwmDriver behavioral architecture in test
configuration TESTBENCH_FOR_PWMDRIVER_BEHAVIORAL of PwmDriver_tb is
    for TB_ARCHITECTURE
        for DUT : PwmDriver
            use entity work.PwmDriver(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_PWMDRIVER_BEHAVIORAL;
