--------------------------------------------------------------------------------
--                                                                            --
--  AddSub1 Test Bench                                                        --
--                                                                            --
--  This is a test bench for the AddSub1 entity. It will test the AddSub1     --
--  implementation architecture for all possible input combinations and       --
--  verify that the outputs are correct. The Testbench entity is called       --
--  AddSub1_TB.                                                               --
--                                                                            --
--  Revision History:                                                         --
--      12/5/2024  Edward Speer  Initial Revision                             --
--                                                                            --
--------------------------------------------------------------------------------

--
-- Imports
--

library ieee;
use     ieee.std_logic_1164.all;

entity AddSub1_TB is
end    AddSub1_TB;

--
-- AddSub1_TB TB_architecture
--

architecture TB_architecture of AddSub1_TB is
    
        --
        -- AddSub1 component declaration
        --

        component AddSub1
            port (
                A    : in  std_logic;  -- First input bit
                B    : in  std_logic;  -- Second input bit
                Sub  : in  std_logic;  -- Subtract control signal
                CIn  : in  std_logic;  -- Carry in bit
                S    : out std_logic;  -- Output bit
                COut : out std_logic   -- Carry out bit
            );
        end component;
    
        --
        -- Stimulus signals
        --

        signal A    : std_logic := '0';  -- First input bit
        signal B    : std_logic := '0';  -- Second input bit
        signal Sub  : std_logic := '0';  -- Subtract control signal
        signal CIn  : std_logic := '0';  -- Carry in bit

        --
        -- Observed signals
        --

        signal S    : std_logic;         -- Output bit
        signal COut : std_logic;         -- Carry out bit

begin

    --
    -- Device under test port map
    --

    DUT : AddSub1 port map (
        A    => A,    -- First input bit
        B    => B,    -- Second input bit
        Sub  => Sub,  -- Subtract control signal
        CIn  => CIn,  -- Carry in bit
        S    => S,    -- Output bit
        COut => COut  -- Carry out bit
    );

    process      -- TEST_PROCESS
    begin
        -- Test all possible addition input combinations
        Sub <= '0';

        A   <= '0';
        B   <= '0';
        CIn <= '0';
        wait for 10 ns;
        assert (S = '0' and COut = '0') report "Test 1 failed" severity ERROR;

        A   <= '0';
        B   <= '1';
        CIn <= '0';
        wait for 10 ns;
        assert (S = '1' and COut = '0') report "Test 2 failed" severity ERROR;

        A   <= '1';
        B   <= '0';
        CIn <= '0';
        wait for 10 ns;
        assert (S = '1' and COut = '0') report "Test 3 failed" severity ERROR;

        A   <= '1';
        B   <= '1';
        CIn <= '0';
        wait for 10 ns;
        assert (S = '0' and COut = '1') report "Test 4 failed" severity ERROR;

        A   <= '0';
        B   <= '0';
        CIn <= '1';
        wait for 10 ns;
        assert (S = '1' and COut = '0') report "Test 1 failed" severity ERROR;

        A   <= '0';
        B   <= '1';
        CIn <= '1';
        wait for 10 ns;
        assert (S = '0' and COut = '1') report "Test 2 failed" severity ERROR;

        A   <= '1';
        B   <= '0';
        CIn <= '1';
        wait for 10 ns;
        assert (S = '0' and COut = '1') report "Test 3 failed" severity ERROR;

        A   <= '1';
        B   <= '1';
        CIn <= '1';
        wait for 10 ns;
        assert (S = '1' and COut = '1') report "Test 4 failed" severity ERROR;

        -- Test all possible subtraction input combinations
        Sub <= '1';

        A   <= '0';
        B   <= '0';
        CIn <= '1';
        wait for 10 ns;
        assert (S = '0' and COut = '1') report "Test 5 failed" severity ERROR;

        A   <= '0';
        B   <= '1';
        CIn <= '1';
        wait for 10 ns;
        assert (S = '1' and COut = '0') report "Test 6 failed" severity ERROR;

        A   <= '1';
        B   <= '0';
        CIn <= '1';
        wait for 10 ns;
        assert (S = '1' and COut = '1') report "Test 7 failed" severity ERROR;

        A   <= '1';
        B   <= '1';
        CIn <= '1';
        wait for 10 ns;
        assert (S = '0' and COut = '1') report "Test 8 failed" severity ERROR;

        A   <= '0';
        B   <= '0';
        CIn <= '0';
        wait for 10 ns;
        assert (S = '1' and COut = '0') report "Test 5 failed" severity ERROR;

        A   <= '0';
        B   <= '1';
        CIn <= '0';
        wait for 10 ns;
        assert (S = '0' and COut = '0') report "Test 6 failed" severity ERROR;

        A   <= '1';
        B   <= '0';
        CIn <= '0';
        wait for 10 ns;
        assert (S = '0' and COut = '1') report "Test 7 failed" severity ERROR;

        A   <= '1';
        B   <= '1';
        CIn <= '0';
        wait for 10 ns;
        assert (S = '1' and COut = '0') report "Test 8 failed" severity ERROR;

        -- We're done, so stop the simulation
        wait;

    end process; -- TEST_PROCESS

end TB_architecture;

configuration TESTBENCH_FOR_ADDSUB1_IMPLEMENTATION of AddSub1_TB is
    for TB_architecture
        for DUT : AddSub1
            use entity work.AddSub1(implementation);
        end for;
    end for;
end TESTBENCH_FOR_ADDSUB1_IMPLEMENTATION;
