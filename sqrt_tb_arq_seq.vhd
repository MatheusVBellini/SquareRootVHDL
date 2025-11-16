-- Author: Matheus Violaro Bellini

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

        -- begin tests
        for i in TEST_VECTOR'range loop
            -- test note
            assert FALSE
                report "Beginning test " & integer'image(i)
                severity note;

            -- load current value
            wait for CLK_PERIOD;
            curr_test := std_logic_vector(to_unsigned(TEST_VECTOR(i), input'length));
            input <= curr_test;
            wait for CLK_PERIOD;

            -- launch computation
            start <= '1';
            wait until finished = '1';
            wait until rising_edge(clk);

            -- check output
            curr_result := std_logic_vector(to_unsigned(RESULT_VECTOR(i), output'length));
            assert (output = curr_result)
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
