--------------------------------------------------------------------------------
--                                                                            --
--  AddSub1 Logic Design                                                      --
--                                                                            --
--  This is an entity declaration and architecture for an extremely simple    --
--  single bit adder/subtractor unit. This will be the basic building block   --
--  for the fully parallel CORDIC16 unit design.                              --
--                                                                            --
--  Inputs:                                                                   --
--           A    - First input bit                                           --
--           B    - Second input bit                                          --
--           Sub  - Subtract control signal                                   --
--           CIn  - Carry in bit                                              --
--                                                                            --
--  Outputs:                                                                  --
--           S    - Output bit                                                --
--           COut - Carry out bit                                             --
--                                                                            --
--  Revision History:                                                         --
--      12/5/24  Edward Speer  Initial Revision                               --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use     ieee.std_logic_1164.all;

--
-- AddSub1 entity declaration
--

entity AddSub1 is 
    port (
        A    : in  std_logic;  -- First input bit
        B    : in  std_logic;  -- Second input bit
        Sub  : in  std_logic;  -- Subtract control signal
        CIn  : in  std_logic;  -- Carry in bit
        S    : out std_logic;  -- Output bit
        COut : out std_logic   -- Carry out bit
    );
end AddSub1;

--
-- AddSub1 implementation architecture
--

architecture implementation of AddSub1 is
begin

    -- Each module is fully concurrent
    S    <= B xor Sub xor A xor CIn;
    COut <= (A and CIn) or ((B xor Sub) and A) or ((b xor Sub) and CIn);

end implementation;
