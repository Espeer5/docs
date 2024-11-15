--------------------------------------------------------------------------------
--                                                                            --
--  PwmAudioPlayer Logic Design                                               --
--                                                                            --
--  This is an entity declaration and architecture definition for the PWM     --
--  audio player system. The system pipelines audio samples from an EPROM     --
--  and outputs the samples via PWM at 8 kHz.                                 --
--                                                                            --
--  Inputs:                                                                   --
--           CLK              - 32MHz system clock                            --
--           RESET            - Asynchronous active high reset                --
--           BTN[3..0]        - 4 input buttons                               --
--           AudioData[7..0]  - Audio sample data input                       --
--                                                                            --
--  Outputs:                                                                  --
--           AudioAddr[18..0] - Address of EPROM to read from                 --
--           AudioPWMOut      - Output audio using PWM                        --
--                                                                            --
--  Revision History:                                                         --
--      11/11/2024  Edward Speer  Initial Revision                            --
--      11/13/2024  Edward Speer  Remap addr & btns to reconfigured modules   --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;

--
-- PwmAudioPlayer entity declaration
--

entity PwmAudioPlayer is
    port (
        CLK         : in     std_logic;                     -- 32 MHz sys clock
        RESET       : in     std_logic;                     -- Asynch reset
        BTN         : in     std_logic_vector(3 downto 0);  -- User buttons in
        AudioData   : in     std_logic_vector(7 downto 0);  -- EPROM data in
        AudioAddr   : buffer std_logic_vector(18 downto 0); -- EPROM addr out
        AudioPWMOut : out    std_logic                      -- PWM output
    );
end PwmAudioPlayer;

--
-- PwmAudioPlayer behavioral architecture
--

architecture behavioral of PwmAudioPlayer is

    --
    -- Component declaration of shared counter module
    --

    component Cntr8ClockDiv
        port (
            CLK      : in     std_logic;                     -- 32 MHz sys clk
            RESET    : in     std_logic;                     -- Async reset
            CLK_8kHz : buffer std_logic;                     -- 8 kHz clk out
            Cntr8    : out    std_logic_vector(7 downto 0)   -- 8 bit cnt out
        );
    end component;

    --
    -- Component declaration of EPROM data address unit
    --

    component AddrUnit
        port (
            CLK_8kHz  : in     std_logic;                    -- 8 kHz clock
            RESET     : in     std_logic;                    -- Async reset
            Btn       : in     std_logic_vector(3 downto 0); -- User buttons in
            AudioAddr : buffer std_logic_vector(18 downto 0);-- 19 bit addr out
            Enable    : buffer std_logic                     -- Enable PWM out
        );
    end component;

    --
    -- Component declaration of PWM driver block
    --

    component PwmDriver
        port (
            CLK_8kHz    : in  std_logic;                    -- 8 kHz clk
            RESET       : in  std_logic;                    -- Asynch reset
            enable      : in  std_logic;                    -- enable pwm out
            AudioData   : in  std_logic_vector(7 downto 0); -- 8 bit sample
            Cntr8       : in  std_logic_vector(7 downto 0); -- 8 bit counter in
            AudioPWMOut : out std_logic                     -- PWM output
        );
    end component;

    --
    -- Signals used to connect up the blocks in the system
    --

    signal CLK_8kHz  : std_logic;
    signal enable    : std_logic;
    signal Cntr8     : std_logic_vector(7 downto 0);

begin

    --
    -- Port maps for each of the components of the system
    -- 

    U1 : Cntr8ClockDiv
        port map (
            CLK      => CLK,
            RESET    => RESET,
            CLK_8kHz => CLK_8kHz,
            Cntr8    => Cntr8
        );

    U2 : AddrUnit
        port map (
            CLK_8kHz  => CLK_8kHz,
            RESET     => RESET,
            Btn       => BTN,
            AudioAddr => AudioAddr,
            Enable    => enable
        );

    U3 : PwmDriver
        port map (
            CLK_8kHz    => CLK_8kHz,
            RESET       => RESET,
            enable      => enable,
            AudioData   => AudioData,
            Cntr8       => Cntr8,
            AudioPWMOut => AudioPWMOut
        );

end behavioral;

-- Configure the PWMAudioPlayer implementation
configuration PWMAudioPlayer_IMPLEMENTATION of PWMAudioPlayer is
    for behavioral
        for U1 : Cntr8ClockDiv
            use entity work.Cntr8ClockDiv(implementation);
        end for;
        for U2 : AddrUnit
            use entity work.AddrUnit(implementation);
        end for;
        for U3 : PwmDriver
            use entity work.PwmDriver(behavioral);
        end for;
    end for;
end PWMAudioPlayer_IMPLEMENTATION;
