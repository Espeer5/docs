--------------------------------------------------------------------------------
--                                                                            --
--  AddrUnit Logic Design                                                     --
--                                                                            --
--  This is an entity declaration and architectures for an address unit that  --
--  serves as the first stage of the PWM Audio Player system. The unit takes  --
--  in the 8 kHz sample clock, and user button inputs. The unit outputs the   --
--  address of the EPROM to be read from to obtain the requested audio        --
--  sample, as well as an audio output enable signal.                         --
--                                                                            --
--  Inputs:                                                                   --
--           CLK_8kHz          - 8 kHz sample clock                           --
--           Btn[3..0]         - User button inputs                           --
--           RESET             - Asynchronous, active high reset              --
--                                                                            --
--  Outputs:                                                                  --
--           AudioAddr[18..0]  - Address output                               --
--           Enable            - Audio output enable signal                   --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- AddrUnit entity declaration
--

entity AddrUnit is
    port (
        CLK_8kHz     : in     std_logic;                    -- 8 kHz sample clk
        RESET        : in     std_logic;                    -- Asynch reset
        Btn          : in     std_logic_vector(3 downto 0); -- User btn inputs
        AudioAddr    : buffer std_logic_vector(18 downto 0);-- Address output
        Enable       : buffer std_logic                     -- Audio out enable
    );
end AddrUnit;

--
-- AddrUnit behavioral architecture
--

architecture behavioral of AddrUnit is

    -- Top end of address range
    signal AddrStop : std_logic_vector(18 downto 0);

    -- Filtered user button presses (Mutually exclusive)
    signal FilBtn   : std_logic_vector(3 downto 0);

    -- Address range indicated by user button presses
    signal BtnAddr0 : std_logic_vector(18 downto 0);
    signal BtnAddr1 : std_logic_vector(18 downto 0);

    -- Button => addresses mapping
    constant B3_START : std_logic_vector(18 downto 0) := "1000000000000000000";
    constant B2_START : std_logic_vector(18 downto 0) := "1001000000000000000";
    constant B1_START : std_logic_vector(18 downto 0) := "1011000000000000000";
    constant B0_START : std_logic_vector(18 downto 0) := "1111100000000000000";
    constant B0_END   : std_logic_vector(18 downto 0) := "1111111111111111111";

begin

    -- Concurrent logic assignments

    -- Filter button presses to be mutually exclusive
    FilBtn(3) <= Btn(3);
    FilBtn(2) <= Btn(2) and not Btn(3);
    FilBtn(1) <= Btn(1) and not Btn(2) and not Btn(3);
    FilBtn(0) <= Btn(0) and not Btn(1) and not Btn(2) and not Btn(3);

    -- Set start & stop addresses for each button press
    BtnAddr0 <= B3_START when FilBtn = "1000" else
                B2_START when FilBtn = "0100" else
                B1_START when FilBtn = "0010" else
                B0_START;

    BtnAddr1 <= B2_START when FilBtn = "1000" else
                B1_START when FilBtn = "0100" else
                B0_START when FilBtn = "0010" else
                B0_END;

    -- Output is enabled when we haven't reached a stop address
    enable <= '1' when std_match(AudioAddr, AddrStop) = FALSE else '0';

    process(CLK_8kHz, RESET)
    begin
        if RESET = '1' then
            AudioAddr <= "0000000000000000000";
            AddrStop  <= "0000000000000000000";
        elsif rising_edge(CLK_8kHz) then
            if std_match(enable, '0') = TRUE then
                -- If we are at the end of the track, wait until a new button
                -- press occurs to load a new address range
                if std_match(FilBtn, "0000") = FALSE then
                    AudioAddr <= BtnAddr0;
                    AddrStop  <= BtnAddr1;
                end if;
            else
                -- Otherwise simply increment the address
                AudioAddr <= std_logic_vector(unsigned(AudioAddr) + 1);
            end if;
        end if;
    end process;

end behavioral;

--
-- AddrUnit implementation architecture
--

architecture implementation of AddrUnit is

    -- Top end of address range
    signal AddrStop : std_logic_vector(18 downto 0);

    -- Filtered user button inputs (mutually exclusive)
    signal FilBtn : std_logic_vector(2 downto 0);

    -- Address range indicated by user button presses
    signal BtnAddr0       : std_logic_vector(18 downto 0);
    signal BtnAddr1       : std_logic_vector(18 downto 0);
    signal BtnAddr1_other : std_logic_vector(13 downto 0);

begin

    -- Concurrent logic assignment

    -- Filter button presses to be mutually exclusive
    FilBtn(2) <= Btn(2) and not Btn(3);
    FilBtn(1) <= Btn(1) and not Btn(2) and not Btn(3);
    FilBtn(0) <= Btn(0) and not Btn(1) and not Btn(2) and not Btn(3);

    -- Compute invididual terms of Button addresses based on simple equations
    BtnAddr0     <= '1' & FilBtn(0) & (FilBtn(0) or FilBtn(1)) & (FilBtn(0) or
                    FilBtn(1) or FilBtn(2)) & FilBtn(0) & "00000000000000";

    BtnAddr1_other <= (others => FilBtn(0));
    BtnAddr1     <= '1' & (FilBtn(1) or FilBtn(0)) & (FilBtn(2) or FilBtn(1) or
                    FilBtn(0)) & '1' & (FilBtn(1) or FilBtn(0))
                    & BtnAddr1_other;

    -- Output is enabled when we haven't reached a stop address
    enable <= '1' when std_match(AudioAddr, AddrStop) = FALSE else '0';

    process(CLK_8kHz, RESET)
    begin
        if RESET = '1' then
            AudioAddr <= "0000000000000000000";
            AddrStop  <= "0000000000000000000";
        elsif rising_edge(CLK_8kHz) then
            if std_match(enable, '0') = TRUE then
                -- If we are at the end of the track, wait until a new button
                -- press occurs to load a new address range
                if std_match(Btn(3) & FilBtn, "0000") = FALSE then
                    AudioAddr <= BtnAddr0;
                    AddrStop  <= BtnAddr1;
                end if;
            else
                -- Otherwise simply increment the address
                AudioAddr <= std_logic_vector(unsigned(AudioAddr) + 1);
            end if;
        end if;
    end process;


end implementation;
