--------------------------------------------------------------------------------
--                                                                            --
--  PwmDriver Logic Design                                                    --
--                                                                            --
--  This is an entity declaration and architecture definition for the PWM     --
--  diver logic for the PWM audio player system. This driver reads in data    --
--  off the data pins, and outputs them as a PWM signal. The output can be    --
--  enabled via an active high enable signal. The block requires both a 32    --
--  MHz system clock input and an 8 kHz clock running at the sampling rate.   --
--                                                                            --
--  Inputs:                                                                   --
--           CLK_32MHz       - 32 MHz system clock                            --
--           CLK_8kHz        - 8 kHz sampling clock                           --
--           AudioData[7..0] - 8 bit audio sample from EPROM                  --
--                                                                            --
--  Outputs:                                                                  --
--           AudioPWMOut     - PWM out                                        --
--                                                                            --
--  Revision History:                                                         --
--      11/11/2024  Edward Speer  Initial Revision                            --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- PwmDriver entity declaration
--

entity PwmDriver is
    port (
        CLK_32MHz   : in std_logic;                    -- 32 Mhz sys clock
        CLK_8kHz    : in std_logic;                    -- 8 kHz sample rate clk
        AudioData   : in std_logic_vector(7 downto 0); -- 8 bit audio sample
        AudioPWMOut : out std_logic                    -- PWM output
    );
end PwmDriver;

--
-- PwmDriver behavioral architecture
--

architecture behavioral of PwmDriver is

    signal cntr        : integer := 0;
    signal audio_cache : std_logic_vector(7 downto 0); -- Holds data sample

begin

    process(CLK_8kHz)  -- LOAD_SAMPLE
    begin
        if rising_edge(CLK_8kHz) then
            audio_cache <= AudioData;
        end if;
    end process;              -- LOAD_SAMPLE

    process(CLK_32MHz) -- OUTPUT
    begin
        if rising_edge(CLK_32MHz) then
            -- Increment & mod counter
            cntr <= (cntr + 1) rem 256;
            if (cntr < unsigned(audio_cache)) then
                AudioPWMOut <= '1';
            else
                AudioPWMOut <= '0';
            end if;
        end if;
    end process;              -- OUTPUT

end behavioral;
