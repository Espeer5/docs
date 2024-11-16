--------------------------------------------------------------------------------
--                                                                            --
--  PwmDriver Logic Design                                                    --
--                                                                            --
--  This is an entity declaration and architectures for a PWM driver module   --
--  that serves as the final stage of the PWM Audio Player system. The unit   --
--  takes in an 8 bit audio sample, an 8 kHz sample clock, and the output of  --
--  the system 8 bit counter. The unit outputs a PWM signal of the correct    --
--  duty cycle to be used as the audio output. The module includes an enable  --
--  signal that may be used to enable or disable the audio output.            --
--                                                                            --
--  Inputs:                                                                   --
--           CLK_8kHz        - 8 kHz sample clock                             --
--           RESET           - Asynch, active hi reset signal                 --
--           enable          - enable audio output                            --
--           AudioData[7..0] - 8 bit audio sample from EPROM                  --
--           Cntr8[7..0]     - 8 bit counter output                           --
--                                                                            --
--  Outputs:                                                                  --
--           AudioPWMOut - PWM output                                         --
--                                                                            --
--  Revision History:                                                         --
--      11/14/2024  Edward Speer  Initial Revision                            --
--                                                                            --        
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- PwmDriver entity declaration
--

entity PwmDriver is
    port (
        CLK_8kHz    : in  std_logic;                    -- 8 kHz sample clock
        RESET       : in  std_logic;                    -- Asynch reset
        enable      : in  std_logic;                    -- enable audio output
        AudioData   : in  std_logic_vector(7 downto 0); -- 8 bit audio sample
        Cntr8       : in  std_logic_vector(7 downto 0); -- 8 bit counter output
        AudioPWMOut : out std_logic                     -- PWM output
    );
end PwmDriver;

--
-- PwmDriver behavioral architecture
--

architecture behavioral of PWMdriver is

    -- Audio data latch
    signal AudioCache : std_logic_vector(7 downto 0);

begin

    -- Concurrent logic assignments

    -- PWM output is computed 16 times per sample period. In each of the 16
    -- periods, the PWM output is high if the counter value is less than the
    -- audio data value. The PWM output is low otherwise.
    AudioPWMOut <= '1' when std_match(enable, '1') = TRUE and
                            unsigned(Cntr8) < unsigned(AudioCache) else '0';

    -- Latch in audio data on the sampling clock
    process(CLK_8kHz, RESET)
    begin
        if std_match(RESET, '1') = TRUE then
            AudioCache <= "00000000";
        elsif rising_edge(CLK_8kHz) then
            AudioCache <= AudioData;
        end if;
    end process;

end behavioral;
