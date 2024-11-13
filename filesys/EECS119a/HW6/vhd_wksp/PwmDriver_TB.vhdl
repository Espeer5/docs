--------------------------------------------------------------------------------
--                                                                            --
--  PwmDriver test bench                                                      --
--                                                                            --
--  This is a test bench for the PwmDriver block of the PWM Audio Player      --
--  system. The test bench thoroughly tests the entity by exercising it and   --
--  checking the output PWM produced. The test bench entity is called         --
--  PwmDriver_tb and it is currently defined to test the behavioral           --
--  architecture of the PwmDriver unit.                                       --
--                                                                            --
--  Revision History:                                                         --
--      11/11/2024  Edward Speer  Initial revision                            --
--      11/12/2024  Edward Speer  Remove dependency on clock divider module   --
--      11/12/2024  Edward Speer  Test implementation architecture            --
--                                                                            --
--------------------------------------------------------------------------------

-- IMPORTS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PwmDriver_tb is
end PwmDriver_tb;

--
-- PwmDriver_tb TB_ARCHITECTURE
--

architecture TB_ARCHITECTURE of PwmDriver_tb is

    --
    -- Component declaration of the DUT
    --

    component PwmDriver
        port (
            CLK_32MHz   : in std_logic;                    -- 32 Mhz sys clock
            CLK_8kHz    : in std_logic;                    -- 8 kHz sample clk
            AudioData   : in std_logic_vector(7 downto 0); -- 8 bit audio sample
            AudioPWMOut : out std_logic                    -- PWM output
        );
    end component;

    --
    -- Stimulus signals
    --

    signal CLK_32MHz : std_logic;
    signal CLK_8kHz  : std_logic;
    signal AudioData : std_logic_vector(7 downto 0) := "00000000";

    --
    -- Observed signals
    --

    signal AudioPWMOut : std_logic := '0';

    --
    -- Flag used to start and end simulation
    --
    signal END_SIM   : BOOLEAN := FALSE;

begin

    --
    -- Device under test port map
    --

    DUT : PwmDriver
        port map (
            CLK_32MHz   => CLK_32MHz,
            CLK_8kHz    => CLK_8kHz,
            AudioData   => AudioData,
            AudioPWMOut => AudioPWMOut
        );

    process(CLK_8kHz) -- STIMULUS_PROCESS

        variable cnt       : integer := 0;
        variable start_cnt : integer := 0;

    begin
        if END_SIM = TRUE then
            report "DONE KILL PROCESS";
        elsif rising_edge(CLK_8kHz) then
            -- Change the AudioData in at 8 kHz
            AudioData <= std_logic_vector(to_unsigned(cnt, 8));
            cnt := cnt + 1;
            if cnt = 255 then
                END_SIM <= TRUE;
            end if;
        end if;
    end process;     -- STIMULUS_PROCESS

    process(CLK_32MHz) -- OBSERVATION_PROCESS

        variable clocks  : integer := 0;
        variable exp_cnt : integer := 0;
        variable pwm_cnt : integer := 0;

    begin
        if END_SIM = FALSE then
            if rising_edge(CLK_32MHz) then
                if std_match(AudioPWMOut, '1') then
                    pwm_cnt := pwm_cnt + 1;
                end if;
                clocks := (clocks + 1) rem 4096;
                if clocks = 4095 then
                    assert (pwm_cnt > 16 * (exp_cnt - 1) - 30)
                        report "PULSE WIDTH TOO SMALL"
                        severity ERROR;
                    assert (pwm_cnt < 16 * (exp_cnt - 1) + 30)
                        report "PULSE WIDTH TOO LARGE"
                        severity ERROR;
                    pwm_cnt := 0;
                    exp_cnt := exp_cnt + 1;
                end if;
            end if;
        end if;
    end process;       -- OBSERVATION_PROCESS

    CLOCK_CLK : process

    -- This process generates both a 32 MHz x 50% duty cycle clock, and an 8 kHz
    -- x 50% duty cycle clock synchronized to the 32 MHz clock, and stops both
    -- clocks when the end of simulation is reached.

    variable clk_cnt : integer := 0; -- Counter on 32 MHz clocks to produce 8kHz

    begin
        -- Generate clock signals
        if END_SIM = FALSE then
            CLK_32MHz <= '0';
            wait for 15625 ps;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            CLK_32MHz <= '1';
            clk_cnt := clk_cnt + 1;
            if clk_cnt = 2048 then
                CLK_8kHz <= '0';
            elsif clk_cnt = 4096 then
                CLK_8kHz <= '1';
                clk_cnt := 0;
            end if;
            wait for 15625 ps;
        else
            wait;
        end if;

    end process; -- CLOCK_CLK

end TB_ARCHITECTURE;

-- Configure use of PwmDriver behavioral architecture
configuration TESTBENCH_FOR_PwmDriver_BEHAVIORAL of PwmDriver_tb is
    for TB_ARCHITECTURE
        for DUT : PwmDriver
            use entity work.PwmDriver(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_PwmDriver_BEHAVIORAL;

-- Configure use of PwmDriver implementation architecture
configuration TESTBENCH_FOR_PwmDriver_IMPLEMENTATION of PwmDriver_tb is
    for TB_ARCHITECTURE
        for DUT : PwmDriver
            use entity work.PwmDriver(implementation);
        end for;
    end for;
end TESTBENCH_FOR_PwmDriver_IMPLEMENTATION;
