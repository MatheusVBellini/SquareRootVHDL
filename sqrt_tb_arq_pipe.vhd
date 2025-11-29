-- Author: Matheus Violaro Bellini

--
-- TESTBENCH FOR A4
--
-- Testbench for testing the pipelined
-- square root calculators.
--
architecture arq_pipe of SQRT_TB is

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
    constant TEST_COUNT    : integer := 5;
    constant TEST_VECTOR   : int_array(0 to TEST_COUNT-1) := (0, 1, 512, 5499030, 119487748);
    constant RESULT_VECTOR : int_array(0 to TEST_COUNT-1) := (0, 1, 22, 2345, 10931);
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

        -- test note
        assert FALSE
            report "Beginning test..."
            severity note;

        for i in TEST_VECTOR'range loop

            -- check that 'finished' is '0'
            assert finished = '0'
                report "Expected 'finished' to be '0' at pipeline value loading iteration " & integer'image(i)
                severity error;

            -- load new value in the pipeline
            wait for CLK_PERIOD;
            curr_test := std_logic_vector(to_unsigned(TEST_VECTOR(i), input'length));
            input <= curr_test;
            start <= '1';

        end loop;
        for i in 1 to (n - TEST_VECTOR'length + 3) loop

            -- check that 'finished' is '0'
            assert finished = '0'
                report "Expected 'finished' to be '0' at pipeline waiting iteration " & integer'image(i)
                severity error;

            -- wait pipeline to be ready
            wait until rising_edge(clk);

        end loop;

        for i in TEST_VECTOR'range loop

            -- check that 'finished' is '1'
            assert finished = '1'
                report "Expected 'finished' to be '1' at pipeline evaluation iteration " & integer'image(i)
                severity error;

            -- verify output results
            curr_result := std_logic_vector(to_unsigned(RESULT_VECTOR(i), output'length));
            assert (output = curr_result)
                report "Expected: " & integer'image(to_integer(unsigned(curr_result))) & ". Got: " &
                    integer'image(to_integer(unsigned(output))) & "."
                severity error;
            wait for CLK_PERIOD;

        end loop;

        -- reset values
        start <= '0';
        wait for CLK_PERIOD;

        -- End simulation
        assert FALSE
            report "Simulation finished."
            severity failure;

    end process TEST;

end arq_pipe;
