--------------------------------------------------------------------------------
--                                                                            --
--  AddrUnit Logic Design                                                     --
--                                                                            --
--  This is an entity declaration and architecture definition for a  19 bit   --
--  address unit used to access the EPROM memory for the PWM audio player.    --
--  The AddrUnit supports two functions, to load in an entire 19 bit address  --
--  and to count up addresses sequentially. If the maximum value of the       --
--  address space is reached, loops back to lowest address. This unit         --
--  requires an 8 kHz input clock signal.                                     --
--                                                                            --
--  Inputs:                                                                   --
--           AddrIn[18..0]    - 19 bit address input                          --
--           Load             - Flag to load from AddrIn                      --
--           CLK              - 8 kHz clock                                   --
--                                                                            --
--  Outputs:                                                                  --
--           AudioAddr[18..0] - 19 bit address output                         --
--                                                                            --
--  Revision History:                                                         --
--      11/10/2024  Edward Speer  Initial Revision                            --
--      11/11/2024  Edward Speer  Clk divider to external                     --
--      11/12/2024  Edward Speer  Add implementation architecture             --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- AddrUnit entity declaration
--

entity AddrUnit is
    port (
        CLK       : in     std_logic;                     -- 8 kHz sys clock
        LOAD      : in     std_logic;                     -- Flag to load AddrIn
        AddrValid : buffer std_logic;                     -- Current addr valid?
        AddrIn    : in     std_logic_vector(18 downto 0); -- 19 bit address in
        AudioAddr : buffer std_logic_vector(18 downto 0); -- 19 bit address out
        AddrStop  : in     std_logic_vector(18 downto 0)  -- Top addr of track
    );
end AddrUnit;

--
-- AddrUnit behavioral architecture
--

architecture behavioral of AddrUnit is

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if std_match(LOAD, '1') = TRUE then
                AudioAddr <= AddrIn;
                AddrValid <= '1';
            else
                if std_match(AudioAddr, AddrStop) then
                    AddrValid <= '0';
                end if;
                if std_match(AudioAddr, "1111111111111111111") then
                    AudioAddr <= "0000000000000000000";
                end if;
                AudioAddr <= std_logic_vector(unsigned(AudioAddr) + 1);
            end if;
        end if;
    end process;

end behavioral;

--
-- AddrUnit implementation architecture
--

architecture implementation of AddrUnit is

    signal cnt19     : unsigned(18 downto 0); -- 19 bit counter
    signal AddrMatch : std_logic;             -- cnt reached AddrStop

begin

    AddrValid <= '0' when (std_match(cnt19, unsigned(AddrStop)) = TRUE) else '1';

    process(CLK)
    begin
        if rising_edge(CLK) then
            cnt19 <= cnt19 + 1;
            with LOAD select
                AudioAddr <= AddrIn when '1',
                             std_logic_vector(unsigned(AudioAddr) + 1) when
                                                                         others;
        end if;
    end process;

end implementation;