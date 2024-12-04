--------------------------------------------------------------------------------
--                                                                            --
--  Div16 Logic Design                                                        -- 
--                                                                            --
--  This is an entity declaration and architecture for a 16-bit divier. This  --
--  design implements 16 bit division using the non-restoring devision        --
--  algorithm. The system takes in two 16-bit numbers from keypad inputs and  --
--  outputs the quotient of the division on the press of the calculate key.   --
--  This divider is implemented serially, meaning there is a single-bit       --
--  adder/subtractor unit used to perform the computations. All input and     --
--  output values are displayed as hex on the 7-segment multiplexed display.  --
--                                                                            --
--  Inputs:                                                                   --
--           nCalculate        : Calculate the quotient (active low)          --
--           nReset            : Asynch active low reset. Used in TB only     --
--           Divisor           : Input values are divisor, not dividend       --
--           KeypadRdy         : Signals new debounced key pattern available  --
--           Keypad[3..0]      : Keypad pattern input                         --
--           CLK               : 1 MHz system clock                           --
--                                                                            --
--  Outputs:                                                                  --
--           HexDigit[3..0]    : Hex digit to display on 7-segment display    --
--           DecoderEn         : Enable for 4:12 digit decoder                --
--           DecoderBits[3..0] : 4-bit input to 4:12 digit decoder            --
--                                                                            --
--  Revision History:                                                         --
--      11/30/2024  Edward Speer  Initial Revision                            --
--      12/01/2024  Edward Speer  Remove nReset signal                        --
--      12/02/2024  Edward Speer  Massive Refactoring                         --
--      12/02/2024  Edward Speer  Fix quotient calculation                    --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;


--
-- Div16 Entity Declaration
--

entity Div16 is
    port (
        CLK         : in  std_logic;                    -- 1MHz sys clock
        nReset      : in  std_logic;                    -- Asynch rst (TB only)
        nCalculate  : in  std_logic;                    -- Calc switch input
        KeypadRdy   : in  std_logic;                    -- Keypad ready signal
        Divisor     : in  std_logic;                    -- Divisor switch input
        Keypad      : in  std_logic_vector(3 downto 0); -- Keypad input
        HexDigit    : out std_logic_vector(3 downto 0); -- Hex digit output
        DecoderEn   : out std_logic;                    -- Enable 4:12 decoder
        DecoderBits : out std_logic_vector(3 downto 0)  -- 4:12 decoder input
    );
end Div16;


--
-- Div16 implementatation architecture
--

architecture implementation of Div16 is

    -- Keypad signals
    signal HaveKey    : std_logic;                    -- Have key input
    signal KeypadRdyS : std_logic_vector(2 downto 0); -- KP rdy synchronization

    -- LED Multiplexer signals
    signal MuxCntr    : unsigned(9 downto 0);         -- Div 1 MHz to 1KHz
    signal DigitClkEn : std_logic;                    -- Enable digit clock
    signal CalcInEn   : std_logic;                    -- Enable calculations
    signal CurDigit   : std_logic_vector(3 downto 0); -- Current mux digit

    -- Signal to select shift register operation
    signal ShiftOp : std_logic_vector(1 downto 0);

    -- Shift register operation codes (assigned to ShiftOp)
    --     ShiftOp = 0  ==>  hold
    --     ShiftOp = 1  ==>  calculate shift
    --     ShiftOp = 2  ==>  keypad input shift
    --     ShiftOp = 3  ==>  display shift
    constant ShiftOpHOLD  : std_logic_vector(1 downto 0) := "00";
    constant ShiftOpCALC  : std_logic_vector(1 downto 0) := "01";
    constant ShiftOpKEYIN : std_logic_vector(1 downto 0) := "10";
    constant ShiftOpSHIFT : std_logic_vector(1 downto 0) := "11";

    -- 12 hex digits in a shift register. Layout before shifting is as follows:
    --    Quotient[15..0] | Divisor[15..0] | Dividend[15..0]
    --    47              | 31             | 15             0
    signal DigitBits : std_logic_vector(47 downto 0);

    -- 17 bit temporary remainder register used in division algorithm
    signal Remainder : std_logic_vector(16 downto 0);

    -- Quotient bit to be shifted into the quotient register at the end of
    -- each 16 bit add/subtract operation
    signal QuotBit   : std_logic;

    -- Counter to keep track of which bit of the dividend is being used and
    -- which bit of add/sub operation is ongoing
    signal DivBit     : Integer range 0 to 15;
    signal AddSubBit  : Integer range 0 to 17; -- Need extra initialization cnt
    signal DONE       : std_logic;             -- Calculation done (active LOW)
    signal CalcRdy    : std_logic;             -- Calculation ready (active HI)

    -- Adder/Subtracter unit control signals
    signal AddSub        : std_logic; -- Add (0) or subtract (1)
    signal CalcResultBit : std_logic; -- Result of add/subtract operation
    signal CalcCarryOut  : std_logic; -- Carry out of add/subtract operation
    signal CarryFlag     : std_logic; -- Latched carry flag 

begin

    -- One-bit adder/subtracter unit to perform calculations on the remainder
    -- register with the divisor.
    CalcResultBit <= DigitBits(16) xor AddSub xor Remainder(0) xor CarryFlag;
    CalcCarryOut  <= (Remainder(0) and CarryFlag) or
                     ((DigitBits(16) xor AddSub) and Remainder(0)) or
                     ((DigitBits(16) xor AddSub) and CarryFlag);

    -- Quotient bit is the carry out of the add/subtract of bit 17 of the 
    -- remainder reg with the Carry/Borrow flag
    QuotBit <= (not AddSub and CalcCarryOut and Remainder(1)) or
               (AddSub and (CalcCarryOut or Remainder(1)));

    process(CLK)  -- LATCH_CARRY
    begin
        if rising_edge(CLK) then
            
            -- Initialize carry flag according to the add/subtract operation
            -- selected by the Add/Sub signal. If subtracting, carry in is set
            -- to use two's complement of the divisor. Initialization occurs
            -- right before calculation, when MuxCntr = 1111100000.
            -- Similarly, signal the start of the computation.
            if (MuxCntr(5) = '0') then
                CarryFlag <= AddSub;
            end if;

            -- Latch carry flag after each bit of calculation
            if (ShiftOp = ShiftOpCALC) then
                CarryFlag <= CalcCarryOut;
            end if;
        end if;
    end process;  -- LATCH_CARRY

    process(CLK)  -- KEY_DETECTION
    begin
        if rising_edge(CLK) then
            -- shift the keypad ready signal to synchronize and edge detect
            KeypadRdyS  <=  KeypadRdyS(1 downto 0) & KeypadRdy;

            -- have a key if have one already that hasn't been processed or a
            -- new one is coming in (rising edge of KeypadRdy), reset if on
            -- the last clock of Digit 3 or Digit 7 (depending on position of
            -- Divisor switch) and held otherwise
            if  (std_match(KeypadRdyS, "01-")) then
                -- set HaveKey on rising edge of synchronized KeypadRdy
                HaveKey <=  '1';
            elsif ((DigitClkEn = '1') and (CurDigit = "0011") and
                                                           (Divisor = '0')) then
                -- reset HaveKey if on Dividend and at end of digit 3
                HaveKey <=  '0';
            elsif ((DigitClkEn = '1') and (CurDigit = "0111") and
                                                           (Divisor = '1')) then
                -- reset HaveKey if on Divisor and at end of digit 7
                HaveKey <=  '0';
            else
                -- otherwise hold the value
                HaveKey <=  HaveKey;
            end if;
        end if;
    end process;  -- KEY_DETECTION

    process(CLK)  -- CLOCK_DIVIDER
    begin
        -- count on the rising edge
        if rising_edge(CLK) then
            -- Reset to 0 on reset - note that reset is tied high in hardware
            -- Used for testbench only
            if (nReset = '0') then
                MuxCntr <= (others => '0');
            else
                MuxCntr <= MuxCntr + 1;
            end if;
        end if;
    end process;  -- CLOCK_DIVIDER

    -- the multiplex counter is also used for controlling the operation of
    -- the circuit - DigitClkEn signals the end of a multiplexed digit
    -- (MuxCntr = 3FF) and CalcInEn signals time periods in which calculations
    -- or inputting may be done (16 clocks - MuxCntr = 11111xxxx0)

    DigitClkEn <= '1' when (MuxCntr = "1111111111")           else '0';
    CalcInEn   <= '1' when (std_match(MuxCntr, "11111----0")) else '0';

    process(CLK)  -- DIGIT_COUNTER
    begin
        if (rising_edge(CLK)) then
            -- create the appropriate count sequence - Order is
            -- 3, 2, 1, 0, 7, 6, 5, 4, 11, 10, 9, 8
            -- Only increment when Digit clock is enabled
            -- reset the decoder to 3 on reset
            -- Note that reset tied high in hardware - only for simulation
            if (nReset = '0') then
                CurDigit <= "0011";
            elsif (DigitClkEn = '1') then
                CurDigit(0) <= not CurDigit(0);
                CurDigit(1) <= CurDigit(1) xor not CurDigit(0);
                if (std_match(CurDigit, "0-00")) then
                    CurDigit(2) <= not CurDigit(2);
                end if;
                if (std_match(CurDigit, "-100") or
                                               std_match(CurDigit, "1-00")) then
                    CurDigit(3) <= not CurDigit(3);
                end if;

            -- otherwise hold the current value
            else
                CurDigit <= CurDigit;

            end if;
        end if;
    end process;  -- DIGIT_COUNTER

    -- always enable the digit decoder
    DecoderEn <= '1';

    -- output the current digit to the digit decoder
    DecoderBits <= CurDigit;

    -- the hex digit to output is just the low nibble of the shift register
    HexDigit <= DigitBits(3 downto 0);

    -- shift register commands
    --    set bit 0 if shifting for display or doing a calculation
    --    set bit 1 if shifting for display or inputting a key (MuxCntr = 3F6)
    ShiftOp <= ShiftOpSHIFT when (DigitClkEn = '1')  else
               ShiftOpKEYIN when ((CalcInEn = '1')   and
                                  (nCalculate = '1') and
                                  (DONE = '0')       and -- Disable keys in calc
                                  (HaveKey = '1')    and
                                  (std_match(MuxCntr, "-----1011-") and
                                (((CurDigit = "0011") and (Divisor = '0')) or
                                 ((CurDigit = "0111") and (Divisor = '1')))))
                            else
                ShiftOpCALC when ((CalcInEn = '1') and
                                 (DONE = '1') and
                                 (CurDigit = "0011")) else
                ShiftOpHOLD;

    -- The shift register
    --    Quitient[15..0] | Divisor[15..0] | Dividend[15..0]
    --    47              | 31             | 15             0
    process(CLK, nReset)  -- SHIFT_REGISTER
    begin
        -- If reset triggered, cancel any calculation in progress
        -- Note that reset is tied high in hardware - only for simulation
        if nReset = '0' then
            DigitBits <= (others => '0');
            DONE <= '0';    -- No calculation in progress
            CalcRdy <= '0'; -- Calculation not ready
        elsif rising_edge(CLK) then
            -- If calculate button is pressed, mark ready to begin calculation
            if (nCalculate = '0' and DONE = '0' and CalcRdy = '0') then
                -- Zero out the remainder
                Remainder <= (others => '0');
                -- Initialize dividend bit counter
                DivBit <= 0;
                -- Ensure we are initially subtracting
                AddSub <= '1';
                -- Mark the calculation as ready to begin
                CalcRdy <= '1';
            end if;
            if MuxCntr = "1111011111" and (CurDigit = "0011") then
                -- In this case, we are ready to begin the calculation
                if CalcRdy = '1' then
                    DONE <= '1';
                    CalcRdy <= '0';
                end if;
                Remainder <= Remainder(15 downto 0) & DigitBits(15);
            end if;
            case ShiftOp is
                when ShiftOpHOLD =>
                    DigitBits <= DigitBits;
                when ShiftOpCALC =>

                    -- If we are add/subbing, increment add/sub bit counter
                    AddSubBit <= AddSubBit + 1;

                    if AddSubBit = 15 then
                        -- If we have finished a full add/sub, rotate both
                        -- the divisor and the dividend and shift the carry out
                        -- into the quotient
                        DigitBits <= DigitBits(46 downto 32) & QuotBit &
                                     DigitBits(16) & DigitBits(31 downto 17) &
                                     DigitBits(14 downto 0) & DigitBits(15);

                        -- Shift the result of the prev add/sub into the
                        -- remainder on the left
                        -- Note - this is a 'cheat' but we don't care about the
                        -- remainder after the calculation is done
                        Remainder <= CalcResultBit & CalcResultBit &
                                                         Remainder(16 downto 2);

                        -- Set the add/sub op for the next step
                        AddSub <= QuotBit;

                        -- Reset add/sub bit counter to LSB
                        AddSubBit <= 0;

                        -- If we have used all bits of the dividend, we are done
                        if DivBit = 15 then
                            DONE <= '0';
                            CalcRdy <= '0';
                            -- Zero the dividend counter so to avoid glitchy
                            -- extra shift on dividend
                            DivBit <= 0;
                        else
                            -- Otherwise, increment the dividend bit counter
                            DivBit <= DivBit + 1;
                        end if;
                    else
                        
                        -- Otherwise, rotate the divisor only
                        DigitBits(31 downto 16) <= 
                                    DigitBits(16) &
                                    DigitBits(31 downto 17);

                        -- Shift the result of the prev add/sub into the
                        -- remainder on the left
                        Remainder <= CalcResultBit & Remainder(16 downto 1);

                    end if;
                when ShiftOpKEYIN =>
                    DigitBits <= DigitBits(47 downto 16) &
                                 DigitBits(11 downto 0)  &
                                 Keypad;
                when ShiftOpSHIFT =>
                    DigitBits <= DigitBits(3 downto 0) & DigitBits(47 downto 4);
                when others =>
                    DigitBits <= DigitBits;
            end case;
        end if;
    end process;  -- SHIFT_REGISTER

end implementation;
