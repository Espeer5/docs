--------------------------------------------------------------------------------
--                                                                            --
--  Btn4Decoder Logic Design                                                  --
--                                                                            --
--  This is an entity declaration and architecture definition for a 4 button  --
--  control decoder. This block is used to take in the user button presses    --
--  and filter them so that only one button press is registered at a time.    --
--  The filtered button press is then passed onto the AddrUnit to load in     --
--  the starting and ending addresses of the sample to play.                  --
--                                                                            --
--  Inputs:                                                                   --
--           CLK        - 32 MHz system clock                                 --
--           enable     - active low enable on button read                    --
--           BTN[3..0]  - 4 button inputs                                     --
--                                                                            --
--  Outputs:                                                                  --
--           LOAD            - Load address signal                            --
--           FilButton[3..0] - filtered button presses                        --
--                                                                            --
--  Revision History:                                                         --
--      11/10/2024  Edward Speer  Initial Revision                            --
--      11/12/2024  Edward Speer  Add implementation architecture             --
--      11/13/2024  Edward Speer  Output buttons, not addresses               --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- Btn4Decoder entity declaration
--

entity Btn4Decoder is
    port (
        CLK        : in     std_logic;                    -- 32 MHz system clock
        BTN        : in     std_logic_vector(3 downto 0); -- 4 button inputs
        FilButton  : out    std_logic_vector(3 downto 0)  -- Filtered btn out
    );
end Btn4Decoder;

--
-- Btn4Decoder implementation architecture
--

architecture implementation of Btn4Decoder is

begin

    process(CLK)
    begin
        if rising_edge(CLK) then

            -- Make button signals mutually exclusive by filtering out any
            -- multiple button pressed states
            FilButton(3) <= BTN(3);
            FilButton(2 downto 0) <= "000";
            if std_match(BTN(3), '0') = TRUE then
                if std_match(BTN(2), '1') = TRUE then
                    FilButton(2) <= '1';
                elsif std_match(BTN(1), '1') = TRUE then
                    FilButton(1) <= '1';
                elsif std_match(BTN(0), '1') = TRUE then
                    FilButton(0) <= '1';
                end if;
            end if;
        end if;
    end process;

end implementation;
