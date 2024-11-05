--------------------------------------------------------------------------------
--                                                                            --
--  ic74194 Sequential Logic Design                                           --
--                                                                            --
--  This is an entity and architecture declaration for a 4-bit bi-directional --
--  shift register. This shift register implements the integrated circuit     --
--  74LS194A. The ic74194 includes an asynchronous global clear.              --
--                                                                            --
--  Inputs:                                                                   --
--           CLK      - Clock signal                                          --
--           CLR      - Asynchronous clear                                    --
--           LSI      - Left shift serial input                               --
--           RSI      - Right shift serial input                              --
--           S[1..0]  - Select signals for shift register mode mux            --
--           DI[3..0] - Parallel data inputs                                  --
--                                                                            --
--  Outputs:                                                                  --
--           DO[3..0] - Data buffer/output signals                            --
--                                                                            --
--  Mode Selection:                                                           --
--                  00 => HOLD                                                --
--                  01 => SHIFT RIGHT                                         --
--                  10 => SHIFT LEFT                                          --
--                  11 => LOAD PARALLEL                                       --
--                                                                            --
--  Revision History:                                                         --
--      10/27/24  Edward Speer    Initial Revision                            --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;


--
-- ic74194 entity declaration
--

entity ic74194 is
    port(
        CLK : in std_logic;                       -- Clock signal
        CLR : in std_logic;                       -- Active low asynch clear
        LSI : in std_logic;                       -- Left shift serial input
        RSI : in std_logic;                       -- Right shift serial input
        S   : in std_logic_vector(1 downto 0);    -- Mode mux select signals
        DI  : in std_logic_vector(3 downto 0);    -- Parallel data input
        DO  : buffer std_logic_vector(3 downto 0) -- Data outputs
    );
end ic74194;


--
-- ic74194 dataFlow architecture
-- 

architecture dataFlow of ic74194 is
begin
    process(CLK, CLR)               -- CLR is asynch, so is in sensitivity list
    begin
        if CLR = '0' then           -- If CLR low, override mux mode behavior
            DO <= "0000";
        elsif rising_edge(CLK) then
            case S is
                when "01"   => DO <= RSI & DO(3 downto 1);  -- 01 => SHIFT RIGHT
                when "10"   => DO <= DO(2 downto 0) & LSI;  -- 10 => SHIFT LEFT
                when "11"   => DO <= DI;                    -- 11 => LOAD
                when others => DO <= DO;                    -- 00 => HOLD
            end case;
        end if;
    end process;
end dataFlow;
