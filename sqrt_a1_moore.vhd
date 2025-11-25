-- Author: Matheus Violaro Bellini

--
-- This architecture implements Newton's algorithm to calculate
-- the integer square-root of a number. Each iteration of the
-- algorithm is performed in one clock-cycle.
--
-- The algorithm implementation follows a Moore State Machine logic.
--
architecture a1_moore of SQRT is

    type t_State is (s_WAIT, s_COMPUTE, s_FINISHED);

    signal state         : t_State;
    signal curr_result   : unsigned(n-1 downto 0);
    signal last_result   : unsigned(n-1 downto 0);
    signal finished_var  : std_logic;

begin
    -- Combinational wires
    finished_var <= '1' when (last_result = curr_result and state = s_COMPUTE) else '0';
    result       <= std_logic_vector(curr_result);

    -- Newton's Algorithm
    process(clk, reset)

    begin
        if (reset = '1') then
            curr_result <= to_unsigned(1,curr_result'length);
            last_result <= (others => '0');
        elsif (rising_edge(clk)) then
            -- state logic
            case state is

                -- WAIT processor demand for a computation
                when s_WAIT =>
                    curr_result <= to_unsigned(1,curr_result'length);
                    last_result <= (others => '0');

                    if (start = '1') then
                        state <= s_COMPUTE;
                    end if;

                -- COMPUTE the square root and output when ready
                when s_COMPUTE =>
                    if (finished_var = '1') then
                        state    <= s_FINISHED;
                        finished <= '1';
                    elsif (unsigned(A) = to_unsigned(0,A'length)) then
                        curr_result <= (others => '0');
                        last_result <= (others => '0');
                    else
                        -- x(k+1) = x(k)-f(x(k))/f'(x(k))
                        last_result <= curr_result;
                        curr_result <= resize(shift_right(curr_result + unsigned(A)/curr_result,1),curr_result'length);
                    end if;

                -- FINISHED state while start = '1'
                when s_FINISHED =>
                    if (start = '0') then
                        finished <= '0';
                        state    <= s_WAIT;
                    end if;

            end case;
        end if;
    end process;

end a1_moore;
