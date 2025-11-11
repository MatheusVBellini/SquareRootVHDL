-- Author: Matheus Violaro Bellini

--
-- This architecture implements Newton's algorithm to calculate
-- the integer square-root of a number. Each iteration of the
-- algorithm is performed in one clock-cycle.
--
-- The algorithm implementation follows a Mealy State Machine logic.
--
architecture a1 of SQRT is

    type t_State is (s_WAIT, s_COMPUTE);

    signal state         : t_State;
    signal curr_result   : unsigned(n-1 downto 0);
    signal last_result   : unsigned(n-1 downto 0);
    signal finished_var  : std_logic;

begin
    -- Combinational wires
    state        <= s_COMPUTE when (start = '1') else s_WAIT; -- Mealy States
    finished_var <= '1' when (last_result = curr_result and state = s_COMPUTE) else '0';
    finished     <= finished_var;
    result       <= std_logic_vector(curr_result);

    -- Newton's Algorithm
    process(clk, reset)

    begin
        if (reset = '1') then
            curr_result <=(others => '1');
            last_result <=(others => '0');
        elsif (rising_edge(clk)) then
            case state is

                -- WAIT processor demand for a computation
                when s_WAIT =>
                    curr_result <= (others => '1');
                    last_result <= (others => '0');

                -- COMPUTE the square root and output when ready
                when s_COMPUTE =>
                    if (finished_var = '0') then
                        -- x(k+1) = x(k)-f(x(k))/f'(x(k))
                        curr_result <= resize(shift_right(curr_result - unsigned(A)/curr_result,1),curr_result'length);
                        last_result <= curr_result;
                    end if;

            end case;
        end if;
    end process;

end a1;
