--------------------------------------------------------------------------------
--                                                                            --
--  Cntr8ClockDiv Logic Design                                                --
--                                                                            --
--  This is an entity declaration and architectures for a clock divider       --
--  module that serves a dual purpose as an 8 bit counter. The unit is an 11  --
--  bit counter that divies the input clock by 4096 to produce an 8 kHz       --
--  output clock, giving the sample rate of the audio. 8 bits of the counter  --
--  are output as an 8 bit counter to be used as a PWM duty cycle generator.  --
--                                                                            --
--  Inputs:                                                                   --
--           CLK         - 32 MHz system clock                                --
--           RESET       - Asynchronous active high reset                     --
--                                                                            --
--  Outputs:                                                                  --
--           CLK_8kHz    - 8 kHz output clock                                 --
--           Cntr8[7..0] - 8 bit counter output                               --
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
-- Cntr8ClockDiv entity declaration
--

entity Cntr8ClockDiv is
    port (
        CLK      : in     std_logic;                     -- 32 MHz system clock
        RESET    : in     std_logic;                     -- Async reset
        CLK_8kHz : buffer std_logic;                     -- 8 kHz output clock
        Cntr8    : out    std_logic_vector(7 downto 0)   -- 8 bit counter output
    );
end Cntr8ClockDiv;

--
-- Cntr8ClockDiv behavioral architecture
--

architecture behavioral of Cntr8ClockDiv is

    -- Counter variable
    signal cnt : unsigned(12 downto 0) := "0000000000000"; -- 11 bit counter

begin

    -- Concurrent logic assignments
    Cntr8 <= std_logic_vector(cnt(7 downto 0)); -- 8 bit counter output

    process(CLK, RESET)
    begin
        if RESET = '1' then
            cnt <= "0000000000000"; -- Reset counter
            CLK_8kHz <= '0'; -- Reset 8 kHz clock
        elsif rising_edge(CLK) then
            cnt <= cnt + 1; -- Increment counter
            if cnt = 2047 then
                CLK_8kHz <= '0'; -- Toggle 8 kHz clock if cnt at max
            end if;
            if cnt = 4095 then
                CLK_8kHz <= '1'; -- Toggle 8 kHz clock if cnt at max
                cnt <= "0000000000000";
            end if;
        end if;
    end process;

end behavioral;

--
-- Cntr8ClockDiv implementation architecture
--

architecture implementation of Cntr8ClockDiv is

    -- Counter variable
    signal cnt : unsigned(10 downto 0); -- 11 bit counter

begin

    -- Concurrent logic assignments
    Cntr8 <= std_logic_vector(cnt(7 downto 0)); -- 8 bit counter output

    process(CLK, RESET)
    begin
        if RESET = '1' then
            cnt <= (others => '0'); -- Reset counter
            CLK_8kHz <= '0'; -- Reset 8 kHz clock
        elsif rising_edge(CLK) then
            cnt <= cnt + 1; -- Increment counter
            if cnt = 2047 then
                CLK_8kHz <= not CLK_8kHz; -- Toggle 8 kHz clock if cnt at max
            end if;
        end if;
    end process;

end implementation;
