--------------------------------------------------------------------------------
--                                                                            --
--  Div16 Testbench                                                           --
--                                                                            --
--  This is a testbench for the Div16 entity. The testbench thoroughly tests  --
--  the entity by exercising it and checking the outputs through the use of   --
--  arrays of test inputs (TestInputn) and expected results (TestOutput).     --
--  The testbench entity is called Div16_TB, and it is configured to test     --
--  the implementation architecture of the Div16 entity.                      --
--                                                                            --
--  Revision History:                                                         --
--      12/01/2024  Edward Speer  Initial revision                            --
--      12/02/2024  Edward Speer  Add additional edge cases                   --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Div16_TB is
end Div16_TB;

---
--- Div16 Testbench Architecture
---

architecture TB_ARCHITECTURE of Div16_TB is

    --
    -- Component Declaration of Device Under Test
    --

    component Div16
        port (
            CLK         : in  std_logic;                    -- 1MHz sys clock
            nReset      : in  std_logic;                    -- Test reset
            nCalculate  : in  std_logic;                    -- Calc switch input
            KeypadRdy   : in  std_logic;                    -- Keypad ready in
            Divisor     : in  std_logic;                    -- Divisor switch in
            Keypad      : in  std_logic_vector(3 downto 0); -- Keypad input
            HexDigit    : out std_logic_vector(3 downto 0); -- Hex digit output
            DecoderEn   : out std_logic;                    -- En 4:12 decoder
            DecoderBits : out std_logic_vector(3 downto 0)  -- 4:12 decoder in
        );
    end component;

    --
    -- Stimulus Signals
    --

    signal CLK         : std_logic := '0';
    signal nReset      : std_logic := '1';
    signal nCalculate  : std_logic := '0';
    signal KeypadRdy   : std_logic := '0';
    signal Divisor     : std_logic := '0';
    signal Keypad      : std_logic_vector(3 downto 0) := "0000";

    --
    -- Observed Signals
    --

    signal HexDigit    : std_logic_vector(3 downto 0);
    signal DecoderEn   : std_logic;
    signal DecoderBits : std_logic_vector(3 downto 0);

    --
    -- Buffer to hold output
    --

    signal output      : std_logic_vector(15 downto 0);

    --
    -- Test vectors
    --

    constant TestLen  : Integer := 7;
    signal TestInput1 : std_logic_vector(16 * TestLen - 1 downto 0);
    signal TestInput2 : std_logic_vector(16 * TestLen - 1 downto 0);
    signal TestOutput : std_logic_vector(16 * TestLen - 1 downto 0);

    --
    -- Flag used to end simulation
    --

    signal END_SIM : BOOLEAN := FALSE;

begin

    --
    -- Device Under Test Port Map
    --

    DUT : Div16 port map (
        CLK         => CLK,
        nReset      => nReset,
        nCalculate  => nCalculate,
        KeypadRdy   => KeypadRdy,
        Divisor     => Divisor,
        Keypad      => Keypad,
        HexDigit    => HexDigit,
        DecoderEn   => DecoderEn,
        DecoderBits => DecoderBits
    );

    -- Initialize the test input and expected output
    TestInput1 <= "0000000000000001" &   -- 1 / 1 = 1
                  "0000000000000010" &   -- 2 / 1 = 2
                  "0000000000000100" &   -- 4 / 2 = 2
                  "0000000000001001" &   -- 9 / 3 = 3
                  "1000000000000000" &   -- 32768 / 16384 = 2 
                  "1111111111111111" &   -- FFFF / 0001 = FFFF
                  "0000000000000001";    -- 0001 / 8001 = 0

    TestInput2 <= "1000000000000001" &   -- 1 / 1 = 1
                  "0000000000000001" &   -- 2 / 1 = 2
                  "0000000000000010" &   -- 4 / 2 = 2
                  "0000000000000011" &   -- 9 / 3 = 3
                  "0100000000000000" &   -- 32768 / 16384 = 2
                  "0000000000000001" &   -- FFFF / 0001 = FFFF
                  "1000000000000001";    -- 0001 / 8001 = 0

    TestOutput <= "0000000000000000" &   -- 1 / 1 = 1
                  "0000000000000010" &   -- 2 / 1 = 2
                  "0000000000000010" &   -- 4 / 2 = 2
                  "0000000000000011" &   -- 9 / 3 = 3
                  "0000000000000010" &   -- 32768 / 16384 = 2
                  "1111111111111111" &   -- FFFF / 0001 = FFFF
                  "0000000000000000";    -- 0001 / 8001 = 0



    --
    -- Stimulus/Observation Process
    --

    STIMULUS : process
    begin

        -- Initialize the inputs to the system
        nReset <= '1';
        nCalculate <= '1';
        Divisor <= '0';
        KeypadRdy <= '0';
        Keypad <= "0000";

        -- First, reset the unit for a few clock cycles
        nReset <= '0';
        wait for 5000 ns;
        nReset <= '1';
        wait for 5000 ns;

        -- Now, loop over the test inputs and check correct outputs
        for i in TestLen - 1 downto 0 loop
            -- Load in the dividend one nibble at a time
            divisor   <= '0';
            for j in 3 downto 0 loop
                Keypad <= TestInput1(16 * i + 4 * j + 3 downto 16 * i + 4 * j);
                KeypadRdy <= '1';
                wait for 50 ms;
                KeypadRdy <= '0';
                wait for 50 ms;
            end loop;
            
            -- Load in the divisor one nibble at a time
            divisor   <= '1';
            for j in 3 downto 0 loop
                Keypad <= TestInput2(16 * i + 4 * j + 3 downto 16 * i + 4 * j);
                KeypadRdy <= '1';
                wait for 50 ms;
                KeypadRdy <= '0';
                wait for 50 ms;
            end loop;

            -- Simulate a press of the calculate button
            nCalculate <= '0';
            wait for 100 ms;
            nCalculate <= '1';

            -- Wait a while for the calculation to finish
            wait for 500 ms;

            -- Now, collect the output by waiting for each nibble to be output
            -- on HexDigit and then storing it in the output buffer
            for l in 11 downto 8 loop
                wait until std_match(DecoderBits,
                                           std_logic_vector(to_unsigned(l, 4)));
                output <= HexDigit & output(15 downto 4);
            end loop;

            -- Wait a bit to allow all changes to output buffer to propagate
            wait for 5 ms;

            -- Check the output against the expected output
            assert std_match(output, TestOutput(16 * i + 15 downto 16 * i))
                report "TEST FAILED"
                severity ERROR;
            
        end loop;

        -- Tests complete, so terminate simulation
        END_SIM <= TRUE;
        wait;

    end process;

    --
    -- Clock Generation Process
    --

    CLOCK_CLK : process
    begin
        -- this process generates a 1 us period, 50% duty cycle clock until 
        -- the simulation ends
        if END_SIM = FALSE then
            CLK <= '0';
            wait for 500 ns;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            CLK <= '1';
            wait for 500 ns;
        else
            wait;
        end if;
    end process;

end TB_ARCHITECTURE;

-- Configure TB_Architecture to use Div16 implementation architecture
configuration TESTBENCH_FOR_DIV16_IMPLEMENTATION of Div16_TB is
    for TB_Architecture
        for DUT : Div16
            use entity work.Div16(implementation);
        end for;
    end for;
end TESTBENCH_FOR_DIV16_IMPLEMENTATION;
