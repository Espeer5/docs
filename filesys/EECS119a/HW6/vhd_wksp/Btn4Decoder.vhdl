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
--      11/12/2024  Edward Speer  Add implementation architecture             --
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

    constant B3_START : std_logic_vector(18 downto 0) := "1000000000000000000";
    constant B2_START : std_logic_vector(18 downto 0) := "1001000000000000000";
    constant B1_START : std_logic_vector(18 downto 0) := "1011000000000000000";
    constant B0_START : std_logic_vector(18 downto 0) := "1111100000000000000";
    constant B0_END   : std_logic_vector(18 downto 0) := "1111111111111111111";

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if std_match(enable, '0') = TRUE then
                if std_match(LOAD, '0') = TRUE then
                    if std_match(BTN(3), '1') = TRUE then
                        LOAD <= '1';
                        Sample0   <= B3_START;
                        SampleEnd <= B2_START;
                    elsif std_match(BTN(2), '1') = TRUE then
                        LOAD <= '1';
                        Sample0   <= B2_START;
                        SampleEnd <= B1_START;
                    elsif std_match(BTN(1), '1') = TRUE then
                        LOAD <= '1';
                        Sample0   <= B1_START;
                        SampleEnd <= B0_START;
                    elsif std_match(BTN(0), '1') = TRUE then
                        LOAD <= '1';
                        Sample0   <= B0_START;
                        SampleEnd <= B0_END;
                    end if;
                end if;
            else
                LOAD <= '0';
            end if;
        end if;
    end process;

end behavioral;

--
-- Btn4Decoder implementation architecture
--

architecture implementation of Btn4Decoder is

    -- Mutually exclusive filtered button input
    signal MtexBtn   : std_logic_vector(2 downto 0);

begin

    process(CLK)
    begin
        if rising_edge(CLK) then

            -- Make button signals mutually exclusive by filtering out any
            -- multiple button pressed states
            MtexBtn(2 downto 0) <= "000";
            if std_match(BTN(2), '1') = TRUE then
                MtexBtn(2) <= '1';
            elsif std_match(BTN(1), '1') = TRUE then
                MtexBtn(1) <= '1';
            elsif std_match(BTN(0), '1') = TRUE then
                MtexBtn(0) <= '1';
            end if;

            -- Only trigger load if no song playing and at least 1 btn pressed
            if std_match(enable, '0') = TRUE then
                if std_match(BTN, "0000") = FALSE then
                    LOAD <= '1';
                end if;
            else
                LOAD <= '0';
            end if;

            -- Initialize all bits of Sample0 to 0
            Sample0 <= (others => '0');

            -- Set specific bits of Sample0 according to logic equations
            Sample0(18) <= '1';
            Sample0(17) <= MtexBtn(0);
            Sample0(14) <= MtexBtn(0);

            if std_match(MtexBtn(1), '1') = TRUE or
               std_match(MtexBtn(0), '1') = TRUE then
                Sample0(16) <= '1';
            end if;

            if std_match(MtexBtn(2), '1') = TRUE or
               std_match(MtexBtn(1), '1') = TRUE or
               std_match(MtexBtn(0), '1') = TRUE then
                Sample0(15) <= '1';
            end if;

            -- Initialize all bits of SampleEnd to filtered value of button 0
            SampleEnd <= (others => MtexBtn(0));

            -- Set specific bits of SampleEnd according to logic equations
            SampleEnd(18) <= '1';
            SampleEnd(15) <= '1';

            if std_match(MtexBtn(1), '1') = TRUE or 
               std_match(MtexBtn(0), '1') = TRUE then
                SampleEnd(17) <= '1';
            end if;
            
            if std_match(MtexBtn(2), '1') = TRUE or
               std_match(MtexBtn(1), '1') = TRUE or
               std_match(MtexBtn(0), '1') = TRUE then
                SampleEnd(16) <= '1';
            end if;

            if std_match(MtexBtn(1), '1') = TRUE or
               std_match(MtexBtn(0), '1') = TRUE then
                SampleEnd(14) <= '1';
            end if;

        end if;
    end process;

end implementation;
