--------------------------------------------------------------------------------
--                                                                            --
--  Btn4Decoder Logic Design                                                  --
--                                                                            --
--  This is an entity declaration and architecture definition for a 4 button  --
--  control decoder. This block is used to take in the user button presses    --
--  and decode them into the appropriate control signals for the audio        --
--  player. This block disables itself when the system is already playing a   --
--  sound, even if the user presses another button during that period.        --
--                                                                            --
--  Inputs:                                                                   --
--           CLK        - 32 MHz system clock                                 --
--           enable     - active low enable on button read                    --
--           BTN[3..0]  - 4 button inputs                                     --
--                                                                            --
--  Outputs:                                                                  --
--           LOAD       - Load address signal                                 --
--           Sample0    - 19 bit starting address of sample to play           --
--           SampleEnd  - 19 bit ending address of sample to play             --
--                                                                            --
--  Revision History:                                                         --
--      11/10/2024  Edward Speer  Initial Revision                            --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;

--
-- Btn4Decoder entity declaration
--

entity Btn4Decoder is
    port (
        CLK        : in     std_logic;                    -- 32 MHz system clock
        BTN        : in     std_logic_vector(3 downto 0); -- 4 button inputs
        enable     : in     std_logic;                    -- active low enable
        LOAD       : buffer std_logic := '0';             -- trigger addr load
        Sample0    : out    std_logic_vector(18 downto 0);-- Low sample addr
        SampleEnd  : out    std_logic_vector(18 downto 0) -- Ending sample addr
    );
end Btn4Decoder;

--
-- Btn4Decoder behavioral architecture
--

architecture behavioral of Btn4Decoder is

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if enable = '0' then
                if LOAD = '0' then
                    if BTN(3) = '1' then
                        LOAD <= '1';
                        Sample0   <= "1000000000000000000";
                        SampleEnd <= "1001000000000000000";
                    elsif BTN(2) = '1' then
                        LOAD <= '1';
                        Sample0   <= "1001000000000000000";
                        SampleEnd <= "1011000000000000000";
                    elsif BTN(1) = '1' then
                        LOAD <= '1';
                        Sample0   <= "1011000000000000000";
                        SampleEnd <= "1111100000000000000";
                    elsif BTN(0) = '1' then
                        LOAD <= '1';
                        Sample0   <= "1111100000000000000";
                        SampleEnd <= "1111111111111111111";
                    end if;
                end if;
            else
                LOAD <= '0';
            end if;
        end if;
    end process;

end behavioral;
