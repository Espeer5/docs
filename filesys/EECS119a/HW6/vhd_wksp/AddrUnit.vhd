--------------------------------------------------------------------------------
--                                                                            --
--  AddrUnit Logic Design                                                     --
--                                                                            --
--  This is an entity declaration and architecture definition for a  19 bit   --
--  address unit used to access the EPROM memory for the PWM audio player.    --
--  The AddrUnit will count up adresses while it is in the valid state, then  --
--  wait for a new button press to load a new address range. This unit        --
--  requires an 8 kHz input clock signal.                                     --
--                                                                            --
--  Inputs:                                                                   --
--           CLK              - 8 kHz clock                                   --
--           Load             - Flag to load from AddrIn                      --
--           FilButton[3..0]  - Filtered buttons in                           --
--                                                                            --
--  Outputs:                                                                  --
--           AudioAddr[18..0] - 19 bit address output                         --
--                                                                            --
--  Revision History:                                                         --
--      11/10/2024  Edward Speer  Initial Revision                            --
--      11/11/2024  Edward Speer  Clk divider to external                     --
--      11/12/2024  Edward Speer  Add implementation architecture             --
--      11/13/2024  Edward Speer  include button => address logic             --
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
        RESET     : in     std_logic;                     -- Asynch reset
        FilButton : in     std_logic_vector(3 downto 0);  -- Filtered buttons in
        AddrValid : buffer std_logic;                     -- Current addr valid?
        AudioAddr : buffer std_logic_vector(18 downto 0)  -- 19 bit address out
    );
end AddrUnit;

--
-- AddrUnit behavioral architecture
--

architecture behavioral of AddrUnit is

    -- Top end of address range
    signal   AddrStop : std_logic_vector(18 downto 0) := "0000000000000000000";

    -- Button => addresses mapping
    constant B3_START : std_logic_vector(18 downto 0) := "1000000000000000000";
    constant B2_START : std_logic_vector(18 downto 0) := "1001000000000000000";
    constant B1_START : std_logic_vector(18 downto 0) := "1011000000000000000";
    constant B0_START : std_logic_vector(18 downto 0) := "1111100000000000000";
    constant B0_END   : std_logic_vector(18 downto 0) := "1111111111111111111";

begin

    process(CLK, RESET)
    begin
        if RESET = '1' then
            AudioAddr <= (others => '0');
            AddrStop  <= (others => '0');
            AddrValid <= '0';
        elsif rising_edge(CLK) then
            if std_match(AudioAddr, AddrStop) = TRUE then
                -- If we are at the end of the track, wait until a new button
                -- press occurs to load a new address range
                addrValid <= '0';
                if std_match(FilButton, "0000") = FALSE then
                    if std_match(FilButton, "1000") = TRUE then
                        AudioAddr <= B3_START;
                        AddrStop  <= B2_START;
                    elsif std_match(FilButton, "0100") = TRUE then
                        AudioAddr <= B2_START;
                        AddrStop  <= B1_START;
                    elsif std_match(FilButton, "0010") = TRUE then
                        AudioAddr <= B1_START;
                        AddrStop  <= B0_START;
                    elsif std_match(FilButton, "0001") = TRUE then
                        AudioAddr <= B0_START;
                        AddrStop  <= B0_END;
                    end if;
                    AddrValid <= '1';
                end if;
            else
                if std_match(AudioAddr, B0_END) then
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

    signal   AddrStop : std_logic_vector(18 downto 0);

begin
    
    AddrValid <= '0' when (std_match(AudioAddr, AddrStop) = TRUE) else '1';

    process(CLK)
    begin
        if rising_edge(CLK) then
            if std_match(AddrValid, '0') = TRUE then
                -- If we are at the end of the track, wait until a new button
                -- press occurs to load a new address range
                if std_match(FilButton, "0000") = FALSE then
                    -- If a button press has been registered, use the following
                    -- logic equations to set the starting and ending addresses
                    -- Initialize all bits of AudioAddr to 0
                    AudioAddr <= (others => '0');

                    -- Set specific bits of AudioAddr by logic equations
                    AudioAddr(18) <= '1';
                    AudioAddr(17) <= FilButton(0);
                    AudioAddr(14) <= FilButton(0);

                    if std_match(FilButton(1), '1') = TRUE or
                    std_match(FilButton(0), '1') = TRUE then
                        AudioAddr(16) <= '1';
                    end if;

                    if std_match(FilButton(2), '1') = TRUE or
                    std_match(FilButton(1), '1') = TRUE or
                    std_match(FilButton(0), '1') = TRUE then
                        AudioAddr(15) <= '1';
                    end if;

                    -- Initialize all bits of AddrStop to value of button 0
                    AddrStop <= (others => FilButton(0));

                    -- Set specific bits of AddrStop by logic equations
                    AddrStop(18) <= '1';
                    AddrStop(15) <= '1';

                    if std_match(FilButton(1), '1') = TRUE or 
                    std_match(FilButton(0), '1') = TRUE then
                        AddrStop(17) <= '1';
                    end if;
                    
                    if std_match(FilButton(2), '1') = TRUE or
                    std_match(FilButton(1), '1') = TRUE or
                    std_match(FilButton(0), '1') = TRUE then
                        AddrStop(16) <= '1';
                    end if;

                    if std_match(FilButton(1), '1') = TRUE or
                    std_match(FilButton(0), '1') = TRUE then
                        AddrStop(14) <= '1';
                    end if;
                end if;
            else
                AudioAddr <= std_logic_vector(unsigned(AudioAddr) + 1);
            end if;
        end if;
    end process;

end implementation;
