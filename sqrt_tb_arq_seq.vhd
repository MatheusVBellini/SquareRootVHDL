-- Author: Matheus Violaro Bellini

--
-- TESTBENCH FOR A1, A2 AND A5
--
-- Testbench for testing the sequential
-- square root calculators.
--
architecture arq_seq of SQRT_TB is

    -- Components
    component SQRT is
        generic(n : integer := 32);
        port (
            A           : in    std_logic_vector(2*n-1 downto 0);
            start       : in    std_logic;
            reset       : in    std_logic;
            clk         : in    std_logic;
            finished    : out   std_logic;
            result      : out   std_logic_vector(n-1 downto 0)
        );
    end component SQRT;

    -- Inputs
    signal input    : std_logic_vector(2*n-1 downto 0) := (others => '0');
    signal start    : std_logic := '0';
    signal reset    : std_logic := '1';
    signal clk      : std_logic := '0';

    -- Outputs
    signal output   : std_logic_vector(n-1 downto 0);
    signal finished : std_logic;

    -- Constants
    type int_array is array (natural range <>) of integer;
    constant TEST_COUNT    : integer := 9;
    constant TEST_VECTOR   : int_array(0 to TEST_COUNT-1) := (0, 1, 3, 15, 127, 512, 5499030, 1194877489, 42949672);
    constant RESULT_VECTOR : int_array(0 to TEST_COUNT-1) := (0, 1, 1, 3, 11, 22, 2345, 34567, 65535);
    constant CLK_PERIOD    : time := 10 ns;

begin

    -- DUT instantiation
    DUT : SQRT
    generic map (n => n)
    port map(
        A        => input,
        start    => start,
        reset    => reset,
        clk      => clk,
        finished => finished,
        result   => output
    );

    -- clk generation
    clk <= not clk after CLK_PERIOD/2;

    -- test flow
    TEST : process

    variable curr_test   : std_logic_vector(input'range);
    variable curr_result : std_logic_vector(output'range);

    begin
        wait on clk;

        -- turn off reset
        wait for 3*CLK_PERIOD;
        reset <= '0';

        -- begin tests
        for i in TEST_VECTOR'range loop
            -- test note
            assert FALSE
                report "Beginning test " & integer'image(i)
                severity note;

            -- load current value
            wait for CLK_PERIOD;
            curr_test := std_logic_vector(to_unsigned(TEST_VECTOR(i), input'length));
            if i = TEST_VECTOR'high then
                curr_test := (63 downto 32 => '0', 31 downto 0 => '1'); -- correction for 2^32 - 1
            end if;
            input <= curr_test;
            wait for CLK_PERIOD;

            -- sanity check : at this point 'finished' should always be '0'
            assert (finished = '0')
                report ">finished< output signal is 1 when it should have been 0. Verify internal control signal logic."
                severity failure;

            -- launch computation
            start <= '1';
            wait until finished = '1';
            wait until rising_edge(clk);

            -- check output
            curr_result := std_logic_vector(to_unsigned(RESULT_VECTOR(i), output'length));
            assert (output = curr_result or unsigned(output) = unsigned(curr_result) + 1) -- +1 case for newton algorithm
                report "Expected: " & integer'image(to_integer(unsigned(curr_result))) & ". Got: " &
                    integer'image(to_integer(unsigned(output))) & "."
                severity error;

            -- reset values
            start <= '0';
        end loop;

        -- End simulation
        assert FALSE
            report "Simulation finished."
            severity failure;

    end process TEST;

end arq_seq;
