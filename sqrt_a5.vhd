-- Author: Matheus Violaro Bellini

--
-- This architecture implements a modified non-restoring integer
-- square root algorithm to calculate the integer square-root of a number.
-- Each iteration of the algorithm is performed in one clock-cycle.
--
-- This implementation is realized with a structural description
-- to better control circuit area.
--
architecture a5 of SQRT is

    signal load     : std_logic;
    signal store    : std_logic;
    signal flush    : std_logic;

    -- intermediate signals
    signal output : unsigned(n-1 downto 0);


begin

    CONTROL_PATH : entity work.sqrt_controller(a1)
        generic map (n => n)
        port map (
            start    => start,
            clk      => clk,
            reset    => reset,
            flush    => flush,
            load     => load,
            store    => store,
            finished => finished
        );

    DATA_PATH : entity work.sqrt_datapath(a1)
        generic map (n => n)
        port map (
            din      => unsigned(A),
            clk      => clk,
            rst_ctrl => flush,
            rst_sys  => reset,
            load     => load,
            store    => store,
            dout     => output
        );

    result <= std_logic_vector(output);

end a5;
