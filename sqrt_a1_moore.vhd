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

begin
    -- Combinational wires
    result <= std_logic_vector(curr_result);

    -- Newton's Algorithm
    process(clk, reset)

        variable result_check : unsigned(curr_result'range);

    begin
        if (reset = '1') then
            curr_result                 <= (others => '0');
            curr_result(n/2+1 downto 0) <= (others => '1'); -- begin in the middle 
            finished                    <= '0';
        elsif (rising_edge(clk)) then
            -- state logic
            case state is

                -- WAIT processor demand for a computation
                when s_WAIT =>
                    curr_result                 <= (others => '0');
                    curr_result(n/2+1 downto 0) <= (others => '1'); -- begin in the middle 
                    finished                    <= '0';

                    if (start = '1') then
                        state <= s_COMPUTE;
                    end if;

                -- COMPUTE the square root and output when ready
                when s_COMPUTE =>
                    -- operation cancelling
                    if (start = '0') then
                        state <= s_WAIT;

                    -- algorithm
                    elsif (unsigned(A) = to_unsigned(0,A'length)) then
                        curr_result <= (others => '0');
                        state       <= s_FINISHED;
                        finished    <= '1';
                    else
                        -- x(k+1) = x(k)-f(x(k))/f'(x(k))
                        result_check := resize(shift_right(curr_result + unsigned(A)/curr_result,1),curr_result'length);
                        curr_result <= result_check;

                        -- check conversion
                        if (result_check = curr_result) then
                            state    <= s_FINISHED;
                            finished <= '1';
                        end if;
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
