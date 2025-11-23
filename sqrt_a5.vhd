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

    signal load_flag     : std_logic;
    signal flush_flag    : std_logic;
    signal finished_flag : std_logic;

    -- intermediate signals
    signal data_path_rst : std_logic;
    signal enable        : std_logic;
    signal output        : unsigned(n-1 downto 0);


begin

    CONTROL_PATH : entity work.sqrt_controller(a1)
        generic map (n => n)
        port map (
            start    => start,
            clk      => clk,
            reset    => reset,
            load     => load_flag,
            flush    => flush_flag,
            finished => finished_flag
        );

    data_path_rst <= flush_flag or reset;
    enable        <= not finished_flag;
    result        <= std_logic_vector(output);
    DATA_PATH : entity work.sqrt_datapath(a1)
        generic map (n => n)
        port map (
            din    => unsigned(A),
            clk    => clk,
            reset  => data_path_rst,
            load   => load_flag,
            enable => enable,
            dout   => output
        );

    finished <= finished_flag;

end a5;
