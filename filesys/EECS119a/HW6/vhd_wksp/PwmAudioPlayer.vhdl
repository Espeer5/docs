--------------------------------------------------------------------------------
--                                                                            --
--  PwmAudioPlayer Logic Designer                                             --
--                                                                            --
--  This is an entity declaration and architecture definition for the PWM     --
--  audio player system. The system pipelines audio samples from an EPROM     --
--  and outputs the samples via PWM at 8 kHz.                                 --
--                                                                            --
--  Inputs:                                                                   --
--           CLK              - 32MHz system clock                            --
--           BTN[3..0]        - 4 input buttons                               --
--           AudioData[7..0]  - Audio sample data input                       --
--                                                                            --
--  Outputs:                                                                  --
--           AudioAddr[18..0] - Address of EPROM to read from                 --
--           AudioPWMOut      - Output audio using PWM                        --
--                                                                            --
--  Revision History:                                                         --
--      11/11/2024  Edward Speer  Initial Revision                            --
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
    -- Component declaration of 32 MHz to 8 kHz clock divider
    --

    component M32ToK8ClockDiv
        port (
            CLK          : in     std_logic; -- 32 MHz input clock
            CLK_8kHz     : buffer std_logic  -- 8 kHz output clock
        );
    end component;

    --
    -- Component declaration of EPROM data address unit
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
    -- Component declaration of button input decoding unit
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
    -- Component declaration of PWM driver block
    --

    component PwmDriver
        port (
            CLK_32MHz   : in std_logic;                    -- 32 Mhz sys clock
            CLK_8kHz    : in std_logic;                    -- 8 kHz sample clk
            AudioData   : in std_logic_vector(7 downto 0); -- 8 bit audio sample
            AudioPWMOut : out std_logic                    -- PWM output
        );
    end component;

    --
    -- Signals used to connect up the blocks in the system
    --

    signal CLK_8kHz  : std_logic;
    signal LOAD      : std_logic;
    signal AddrValid : std_logic;
    signal AddrIn    : std_logic_vector(18 downto 0);
    signal AddrStop  : std_logic_vector(18 downto 0);

begin

    --
    -- Port maps for each of the components of the system
    -- 

    U1 : M32ToK8ClockDiv
        port map (
            CLK      => CLK,
            CLK_8kHz => CLK_8kHz
        );

    U2 : AddrUnit
        port map (
            CLK       => CLK_8kHz,
            LOAD      => LOAD,
            AddrIn    => AddrIn,
            AudioAddr => AudioAddr,
            AddrValid => AddrValid,
            AddrStop  => AddrStop
        );

    U3 : Btn4Decoder
        port map (
            CLK       => CLK,
            BTN       => BTN,
            enable    => AddrValid,
            LOAD      => LOAD,
            Sample0   => AddrIn,
            SampleEnd => AddrStop
        );

    U4 : PwmDriver
        port map (
            CLK_32MHz   => CLK,
            CLK_8kHz    => CLK_8kHz,
            AudioData   => AudioData,
            AudioPWMOut => AudioPWMOut
        );

end behavioral;

-- Configure the PWMAudioPlayer implementation
configuration PWMAudioPlayer_IMPLEMENTATION of PWMAudioPlayer is
    for behavioral
        for U1 : M32ToK8ClockDiv
            use entity work.M32ToK8ClockDiv(implementation);
        end for;
        for U2 : AddrUnit
            use entity work.addrUnit(implementation);
        end for;
        for U3 : Btn4Decoder
            use entity work.Btn4Decoder(implementation);
        end for;
        for U4 : PwmDriver
            use entity work.PwmDriver(implementation);
        end for;
    end for;
end PWMAudioPlayer_IMPLEMENTATION;
