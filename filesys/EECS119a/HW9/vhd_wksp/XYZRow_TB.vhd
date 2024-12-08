--------------------------------------------------------------------------------
--                                                                            --
--  XYZRow Testbench                                                          --
--                                                                            --
--  This is a testbench XYZRow entity of the CORDIC16 unit design. It will    --
--  test the XYZRow DataFlow architecture for an extensive range of input     --
--  values and verify that the outputs are correct. The testbench entity is   --
--  called XYZRow_TB.                                                         --
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

entity XYZRow_TB is
end    XYZRow_TB;

--
-- XYZRow_TB TB_architecture
--

architecture TB_architecture of XYZRow_TB is

    --
    -- Component declaration of XYZRow
    --

    component XYZRow
        port (
            N    : in  integer range 0 to 16;          -- Row number
            XIn  : in  std_logic_vector(19 downto 0);  -- X input buffer
            YIn  : in  std_logic_vector(19 downto 0);  -- Y input buffer
            ZIn  : in  std_logic_vector(19 downto 0);  -- Z input buffer
            Cst  : in  std_logic_vector(19 downto 0);  -- Constant val for Z sum
            m    : in  std_logic_vector(1 downto  0);  -- CORDIC coordinate mode
            di   : in  std_logic;                      -- CORDIC decision var
            XOut : out std_logic_vector(19 downto 0);  -- X buffer out
            YOut : out std_logic_vector(19 downto 0);  -- Y buffer out
            ZOut : out std_logic_vector(19 downto 0)   -- Z buffer out
        );
    end component;

    --
    -- Stimulus signals
    --

    signal XIn  : std_logic_vector(19 downto 0);  -- X input buffer
    signal YIn  : std_logic_vector(19 downto 0);  -- Y input buffer
    signal ZIn  : std_logic_vector(19 downto 0);  -- Z input buffer
    signal Cst  : std_logic_vector(19 downto 0);  -- Constant val for Z sum
    signal di   : std_logic;                      -- CORDIC decision variable
    signal m    : std_logic_vector(1 downto  0);  -- CORDIC coordinate mode

    --
    -- Observed signals
    --

    signal XOut : std_logic_vector(19 downto 0);  -- X buffer out
    signal YOut : std_logic_vector(19 downto 0);  -- Y buffer out
    signal ZOut : std_logic_vector(19 downto 0);  -- Z buffer out

    --
    -- Test vectors
    --

    constant nTests : Integer := 2;
    signal XIns     : std_logic_vector(20 * nTests - 1 downto 0);
    signal YIns     : std_logic_vector(20 * nTests - 1 downto 0);
    signal ZIns     : std_logic_vector(20 * nTests - 1 downto 0);
    signal Csts     : std_logic_vector(20 * nTests - 1 downto 0);
    signal dis      : std_logic_vector(nTests - 1      downto 0);
    signal ms       : std_logic_vector(2 * nTests - 1  downto 0);
    signal XOuts    : std_logic_vector(20 * nTests - 1 downto 0);
    signal YOuts    : std_logic_vector(20 * nTests - 1 downto 0);
    signal ZOuts    : std_logic_vector(20 * nTests - 1 downto 0);

begin

    --
    -- Device under test port map
    --

    DUT : XYZRow port map (
        N    => 1,    -- Row number
        XIn  => XIn,  -- X input buffer
        YIn  => YIn,  -- Y input buffer
        ZIn  => ZIn,  -- Z input buffer
        Cst  => Cst,  -- Constant val for Z sum
        di   => di,   -- CORDIC decision variable
        m    => m,    -- CORDIC coordinate mode
        XOut => XOut, -- X buffer out
        YOut => YOut, -- Y buffer out
        ZOut => ZOut  -- Z buffer out
    );

    -- Test vectors
    XIns  <= "01010101010101010101" &
             "01010101010101010101";
    YIns  <= "01010101010101010101" &
             "10101010101010101010";
    ZIns  <= "11111111111111111111" &
             "11111111111111111111";
    Csts  <= "11111111111111111111" &
             "11111111111111111111";
    dis   <= "0" &
             "1";
    ms    <= "10" &
             "10";
    XOuts <= "11111111111111111111" &
             "00000000000000000001";
    YOuts <= "11111111111111111111" &
             "00000000000000000000";
    ZOuts <= "00000000000000000000" &
             "11111111111111111110";

    process      -- TEST_PROCESS
    begin

        -- Initialize the input signals
        XIn  <= (others => '0');
        YIn  <= (others => '0');
        ZIn  <= (others => '0');
        Cst  <= (others => '0');
        di   <= '0';
        m    <= "00";

        wait for 100 ns;

        for i in 0 to nTests - 1 loop
            XIn <= XIns(20 * i + 19 downto 20 * i);
            YIn <= YIns(20 * i + 19 downto 20 * i);
            ZIn <= ZIns(20 * i + 19 downto 20 * i);
            Cst <= Csts(20 * i + 19 downto 20 * i);
            di  <= dis(i);
            m   <= ms(2 * i + 1 downto 2 * i);
            wait for 10 ns;
            assert (XOut = XOuts(20 * i + 19 downto 20 * i) and
                    YOut = YOuts(20 * i + 19 downto 20 * i) and
                    ZOut = ZOuts(20 * i + 19 downto 20 * i))
                report "Test failed" severity ERROR;
        end loop;

        -- End the test
        wait;

    end process;

end TB_architecture;

configuration TESTBENCH_FOR_XYZROW_DATAFLOW of XYZRow_TB is
    for TB_architecture
        for DUT : XYZRow
            use entity work.XYZRow(DataFlow);
        end for;
    end for;
end TESTBENCH_FOR_XYZROW_DATAFLOW;
