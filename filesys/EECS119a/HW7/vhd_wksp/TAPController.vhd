--------------------------------------------------------------------------------
--                                                                            --
--  TAPController Logic Design                                                --
--                                                                            --
--  This is an entity declaration and architecture definition for a JTAG TAP  --
--  controller state machine. The system take in the JTAG test mode select    --
--  signal, JTAG test clock, and JTAG test data input signals and outputs     --
--  the JTAG test data output signal. The controller maintains two internal   --
--  queues for the JTAG data register (32 bits) and the JTAG instruction      --
--  register (7 bits).                                                        --
--                                                                            --
--  This controller will work with the TAPController test bench without       --
--  edit.                                                                     --
--                                                                            --
--  Inputs:                                                                   --
--           TRST  -  JTAG test reset signal                                  --
--           TMS   -  JTAG test mode select signal                            --
--           TDI   -  JTAG test data input signal                             --
--           TCK   -  JTAG test clock signal                                  --
--                                                                            --
--  Outputs:                                                                  --
--           TDO   -  JTAG test data output signal                            --
--                                                                            --
--  Revision History:                                                         --
--      11/19/2024  Edward Speer  Initial Revision                            --
--      11/20/2024  Edward Speer  Enhance documentation                       --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use ieee.std_logic_1164.all;

--
-- TAPController entity declaration
--

entity TAPController is
    port(
        TRST  :  in  std_logic; -- JTAG synchronous reset signal
        TMS   :  in  std_logic; -- JTAG test mode select signal
        TDI   :  in  std_logic; -- Test data in
        TCK   :  in  std_logic; -- Test clock
        TDO   :  out std_logic  -- Test data out
    );
end TAPController;

--
-- TAPController behavioral architecture
--

architecture behavioral of TAPController is

    --
    -- Type declaration of the 10 states in the controller state machine
    --

    type states is (
        RESET,       -- Reset state
        IDLE,        -- Idle state
        DSELECT,     -- Select data register state
        ISELECT,     -- Select instruction register state
        CAPTURE,     -- Begin capture on selected register
        SHIFT,       -- Shift data from TDI into selected register and out TDO
        EXIT1,       -- Either exit to IDLE or PAUSE
        PAUSE,       -- Pause state - Can either wait or exit to EXIT2
        EXIT2,       -- Either exit to update or resume shifting
        UPDATE       -- Save shifted data to selected register and exit to IDLE
    );

    --
    -- Registers
    --

    signal DR : std_logic_vector(31 downto 0);  -- Data register
    signal IR : std_logic_vector(6 downto 0);   -- Instruction register

    --
    -- State signals
    --

    signal current_state : states;     -- Signal for the current state
    signal next_state    : states;     -- Signal for the next state
    signal DR_selected   : std_logic;  -- high if DR selected, low for IR

begin

    process(TCK)                 -- UPDATE_CURRENT_STATE
    begin
        if rising_edge(TCK) then
            if TRST = '1' then  -- Test reset signal is synchronous
                current_state <= RESET;
            else
                current_state <= next_state;

            end if;
        end if;
    end process;                 -- UPDATE_CURRENT_STATE

    process(current_state, TMS)  -- NEXT_STATE_LOGIC
    begin
        case current_state is
            when RESET =>
                if TMS = '1' then
                    next_state <= RESET;
                else
                    next_state <= IDLE;
                end if;
            when IDLE =>
                if TMS = '1' then
                    next_state <= DSELECT;
                else
                    next_state <= IDLE;
                end if;
            when DSELECT =>
                if TMS = '1' then
                    next_state <= ISELECT;
                else
                    next_state <= CAPTURE;
                end if;
            when ISELECT =>
                if TMS = '1' then
                    next_state <= RESET;
                else
                    next_state <= CAPTURE;
                end if;
            when CAPTURE =>
                if TMS = '1' then
                    next_state <= EXIT1;
                else
                    next_state <= SHIFT;
                end if;
            when SHIFT =>
                if TMS = '1' then
                    next_state <= EXIT1;
                else
                    next_state <= SHIFT;
                end if;
            when EXIT1 =>
                if TMS = '1' then
                    next_state <= UPDATE;
                else
                    next_state <= PAUSE;
                end if;
            when PAUSE =>
                if TMS = '1' then
                    next_state <= EXIT2;
                else
                    next_state <= PAUSE;
                end if;
            when EXIT2 =>
                if TMS = '1' then
                    next_state <= UPDATE;
                else
                    next_state <= SHIFT;
                end if;
            when UPDATE =>
                if TMS = '1' then
                    next_state <= DSELECT;
                else
                    next_state <= IDLE;
                end if;
        end case;
    end process;                 -- NEXT_STATE_LOGIC

    process(TCK)                 -- SHIFT_LOGIC
    begin
        if rising_edge(TCK) then
            if current_state = DSELECT then
                DR_selected <= '1';     -- DR selected for scan
            elsif current_state = ISELECT then
                DR_selected <= '0';     -- DR not selected, so IR selected
            elsif current_state = SHIFT then
                -- Shift data into selected register according to DR_selected
                if DR_selected = '1' then
                    DR <= TDI & DR(31 downto 1);
                else
                    IR <= TDI & IR(6 downto 1);
                end if;
            end if;
        end if;
    end process;                 -- SHIFT_LOGIC

    process(DR, IR, DR_selected) -- OUTPUT_LOGIC
    begin
        -- Output the LSB of the selected register
        if DR_selected = '1' then
            TDO <= DR(0);
        else
            TDO <= IR(0);
        end if;
    end process;                 -- OUTPUT_LOGIC

end behavioral;
