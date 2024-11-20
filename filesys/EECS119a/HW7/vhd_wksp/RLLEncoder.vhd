--------------------------------------------------------------------------------
--                                                                            --
--  RLLEncoder Logic Design                                                   --
--                                                                            --
--  This is an entity declaration and architecture definition for an          --
--  RLL(2, 7) econding state machine. The system takes in a serial bit        --
--  stream at half of the system clock rate and outputs a serial bit stream   --
--  giving the RLL encoded input data at the system clock rate. The output    --
--  data is delayed by 2 bits from the input data, meaning that on input of   --
--  an input bit, it will take 4 clock cycles to see the corresponding        --
--  output.                                                                   --
--                                                                            --
--  This encoder will work with the RLLEncoder test bench without edit.       --
--                                                                            --
--  Inputs:                                                                   --
--           DataIn  -  Input data bit                                        --
--           Reset   -  Active low reset signal                               --
--           CLK     -  System clock signal                                   --
--                                                                            --
--  Outputs:                                                                  --
--           RLLOut  -  RLL encoded output data bit                           --
--                                                                            --
--  Revision History:                                                         --
--      11/18/2024  Edward Speer  Initial Revision                            --
--      11/20/2024  Edward Speer  Enhance documentation                       --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use ieee.std_logic_1164.all;

--
-- RLLEncoder entity declaration
--

entity RLLEncoder is
    port (
        DataIn  : in  std_logic;  -- Input data bit
        Reset   : in  std_logic;  -- Active low asynchronous reset signal
        CLK     : in  std_logic;  -- System clock signal
        RLLOut  : out std_logic   -- RLL encoded output data bit
    );
end RLLEncoder;

--
-- RLLEncoder behavioral architecture
--

architecture behavioral of RLLEncoder is

    -- The state machine has 15 states, 1-14, without any straightforward
    -- interpretation associated with each state
    type states is (S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13,
                    S14);

    -- Create a signal for the current state
    signal current_state : states;

    -- Create a signal for the next state
    signal next_state : states;

begin

    process(CLK, Reset)            -- UPDATE_CURRENT_STATE
    begin
        if Reset = '0' then
            current_state <= S5;
        elsif rising_edge(CLK) then
            current_state <= next_state;
        end if;
    end process;                   -- UPDATE_CURRENT_STATE

    process(current_state, DataIn) -- NEXT_STATE_LOGIC
    begin
        case current_state is
            when S1 => next_state <= S2;
            when S2 => next_state <= S3;
            when S3 =>
                if DataIn = '1' then
                    next_state <= S4;
                else
                    next_state <= S5;
                end if;
            when S4 => next_state <= S6;
            when S5 =>
                if DataIn = '1' then
                    next_state <= S1;
                else
                    next_state <= S7;
                end if;
            when S6 =>
                if DataIn = '1' then
                    next_state <= S8;
                else
                    next_state <= S9;
                end if;
            when S7 => next_state <= S10;
            when S8 => next_state <= S3;
            when S9 => next_state <= S11;
            when S10 => next_state <= S11;
            when S11 => 
                if DataIn = '1' then
                    next_state <= S12;
                else
                    next_state <= S13;
                end if;
            when S12 => 
                if DataIn = '1' then
                    next_state <= S3;
                else
                    next_state <= S14;
                end if;
            when S13 =>
                if DataIn = '1' then
                    next_state <= S11;
                else
                    next_state <= S3;
                end if;
            when S14 => next_state <= S5;
        end case;
    end process;                   -- NEXT_STATE_LOGIC

    process(current_state)         -- OUTPUT_LOGIC
    begin
        case current_state is
            when S2 | S6 | S10 | S14 =>
                 RLLOut <= '1';
            when others => RLLOut <= '0';
        end case;
    end process;                   -- OUTPUT_LOGIC

end behavioral;
