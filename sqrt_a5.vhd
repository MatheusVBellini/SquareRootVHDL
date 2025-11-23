-- Author: Matheus Violaro Bellini

--
-- This architecture implements a modified non-restoring integer
-- square root algorithm to calculate the integer square-root of a number.
-- Each iteration of the algorithm is performed in one clock-cycle.
--
-- This implementation is realizaed with a structural description
-- to better control circuit area.
--
use work.utils_pkg.all;

architecture a2 of SQRT is

    type t_State is (s_WAIT, s_COMPUTE);

    signal state : t_State;
    signal D     : unsigned(2*n+1 downto 0); -- 2*n-1 bits (+2 : multiplication by 4)
    signal R     : signed(n+3 downto 0);     -- n-1 bits (+2 : multiplication by 4) (+1 sum) (+1 sign)
    signal Z     : unsigned(n+2 downto 0);   -- n-1 bits (+2 : multiplication by 4) (+1 sum)
    signal iter  : unsigned(bits_needed(n+1)-1 downto 0);

begin
    -- Combinational wires
    state    <= s_COMPUTE when (start = '1') else s_WAIT; -- Mealy States
    result   <= std_logic_vector(Z(result'length-1 downto 0));
    finished <= '1' when (iter = n and state = s_COMPUTE) else '0';

    -- Modified non-restoring integer square root algorithm
    process(clk, reset)

        variable R_next : signed(n+3 downto 0);

    begin
        if (reset = '1') then
            D    <= unsigned(A) & "00";
            R    <= (others => '0');
            Z    <= (others => '0');
            iter <= (others => '0');
        elsif (rising_edge(clk)) then
            case state is

                -- WAIT processor demand for a computation
                when s_WAIT =>
                    Z    <= (others => '0');
                    D    <= unsigned(A) & "00";
                    R    <= (others => '0');
                    iter <= (others => '0');

                -- COMPUTE the square root and output when ready
                when s_COMPUTE =>
                    -- algorithm
                    if (unsigned(A) = to_unsigned(0,A'length)) then
                        Z    <= (others => '0');
                        iter <= to_unsigned(n,iter'length);
                    elsif (iter <= n-1) then

                        iter <= iter + 1;
                    end if;

            end case;
        end if;
    end process;

end a2;
