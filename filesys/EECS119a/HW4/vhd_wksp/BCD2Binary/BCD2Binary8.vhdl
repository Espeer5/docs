--------------------------------------------------------------------------------
--                                                                            --
--  BCD2Binary8 Combinatorial Logic Design                                    --
--                                                                            --
--  This is an entity and architecture declaration for a combinatorial        --
--  circuit which converts an 8-bit BCD value into an 8-bit binary value.     --
--  This design assumes the input will be a valid 8-bit BCD value.            --
--                                                                            --
--  Inputs:                                                                   --
--           BCD[7..0] - 8-bit BCD value to convert to binary                 --
--                                                                            --
--  Outputs:                                                                  --
--           B[7..0] - 8-bit binary value converted from BCD                  --
--                                                                            --
--  Revision History:                                                         --
--      10/27/24  Edward Speer    Initial Revision                            --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- BCD2Binary8 entity declaration
--

entity BCD2Binary8 is
    port (
        BCD : in  std_logic_vector(7 downto 0);    -- 8-bit BCD in
        B   : out std_logic_vector(7 downto 0)     -- 8-bit Binary out
    );
end BCD2Binary8;


--
-- BCD2Binary8 dataFlow architecture
--

architecture dataFlow of BCD2Binary8 is
begin
    B <= std_logic_vector(

        -- Multiply the high nibble by 10, using left shifts: 10 = 2^3 + 2^1
        -- Pad operations on high nibble out to 8-bit to avoid overflow
        (unsigned("0000" & BCD(7 downto 4)) sll 3) +
        (unsigned("0000" & BCD(7 downto 4)) sll 1) + 

        -- Pad the low nibble out to 8-bit to avoid overflow
        unsigned("0000" & BCD(3 downto 0))
    );
end dataFlow;
