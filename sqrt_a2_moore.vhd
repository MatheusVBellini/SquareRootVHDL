-- Author: Matheus Violaro Bellini

--
-- This architecture implements a modified non-restoring integer
-- square root algorithm to calculate the integer square-root of a number.
-- Each iteration of the algorithm is performed in one clock-cycle.
--
-- The algorithm implementation follows a Moore State Machine logic.
--
architecture a2_moore of SQRT is

    type t_State is (s_WAIT, s_COMPUTE, s_FINISHED);

    signal state : t_State;
    signal D     : unsigned(2*n+1 downto 0); -- 2*n-1 bits (+2 : multiplication by 4)
    signal R     : signed(n+3 downto 0);     -- n-1 bits (+2 : multiplication by 4) (+1 sum) (+1 sign)
    signal Z     : unsigned(n+2 downto 0);   -- n-1 bits (+2 : multiplication by 4) (+1 sum)
    signal iter  : integer range 0 to n;

begin
    -- Combinational wires
    result   <= std_logic_vector(Z(result'length-1 downto 0));

    -- Modified non-restoring integer square root algorithm
    process(clk, reset)

        variable R_next : signed(n+3 downto 0);

    begin
        if (reset = '1') then
            D    <= unsigned(A) & "00";
            R    <= (others => '0');
            Z    <= (others => '0');
            iter <= 0;
        elsif (rising_edge(clk)) then
            case state is

                -- WAIT processor demand for a computation
                when s_WAIT =>
                    Z    <= (others => '0');
                    D    <= unsigned(A) & "00";
                    R    <= (others => '0');
                    iter <= 0;

                    if (start = '1') then
                        state <= s_COMPUTE;
                    end if;

                -- COMPUTE the square root and output when ready
                when s_COMPUTE =>
                    -- algorithm
                    if (iter = n) then
                        finished <= '1';
                        state    <= s_FINISHED;
                    elsif (unsigned(A) = to_unsigned(0,A'length)) then
                        Z    <= (others => '0');
                        iter <= n;
                    else
                        -- update R
                        if (R >= to_signed(0,R'length)) then
                            R_next :=   shift_left(R,2)
                                      + to_signed(to_integer(D(D'high downto D'high-1)),R'length)
                                      - resize(signed(shift_left(Z,2)),R'length)
                                      - 1;
                            R <= R_next;
                        else
                            R_next :=   shift_left(R,2)
                                      + to_signed(to_integer(D(D'high downto D'high-1)),R'length)
                                      + resize(signed(shift_left(Z,2)),R'length)
                                      + 3;
                            R <= R_next;
                        end if;

                        -- update Z
                        if (R_next >= 0) then
                            Z <= shift_left(Z,1) + 1;
                        else
                            Z <= shift_left(Z,1);
                        end if;

                        D <= shift_left(D,2);
                        iter <= iter + 1;
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

end a2_moore;
