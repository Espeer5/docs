--------------------------------------------------------------------------------
--                                                                            --
--  M32ToK8ClockDiv Logic Design                                              --
--                                                                            --
--  This is an entity declaration and architecture definition for a 32 MHz    --
--  to 8 kHz clock divider.                                                   --
--                                                                            --
--  Inputs:                                                                   --
--           CLK      - 32 MHz system clock                                   --
--                                                                            --
--  Outputs:                                                                  --
--           CLK_8kHz - 8 kHz clock                                           --
--                                                                            --
--  Revision History:                                                         --
--      11/10/2024  Edward Speer  Initial Revision                            --
--      11/11/2024  Edward Speer  Assume 4096 clocks per period               --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;

--
-- M32ToK8ClockDiv entity declaration
--

entity M32ToK8ClockDiv is
    port (
        CLK          : in     std_logic;  -- 32 MHz input clock
        CLK_8kHz     : buffer std_logic   -- 8kHz output clock
    );
end M32ToK8ClockDiv;

--
-- M32ToK8ClockDiv behavioral architecture
--

architecture behavioral of M32ToK8ClockDiv is

    signal cntr      : integer := 0;
    constant DIVIDER : integer := 2048; -- Top value of counter

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Toggle output clock at CLK / DIVIDER
            if cntr = DIVIDER then
                CLK_8kHz <= '0';
                cntr     <= cntr + 1;
            elsif cntr = 2 * DIVIDER then
                CLK_8kHz <= '1';
                cntr     <= 0;
            else
                cntr <= cntr + 1;
            end if;
        end if;
    end process;

end behavioral;
