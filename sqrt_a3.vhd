-- Author: Matheus Violaro Bellini

--
-- This architecture implements a modified non-restoring integer
-- square root algorithm to calculate the integer square-root of a number.
--
-- This implementation is fully combinatorial.
--
use work.utils_pkg.all;

-- Questions to the professor:
-- 1. Should I still use the control signals?
--      e.g. start, result

architecture a3 of SQRT is

    constant iterations : natural := n;

    signal D     : unsigned(2*n+1 downto 0); -- 2*n-1 bits (+2 : multiplication by 4)
    signal R     : signed(n+3 downto 0);     -- n-1 bits (+2 : multiplication by 4) (+1 sum) (+1 sign)
    signal Z     : unsigned(n+2 downto 0);   -- n-1 bits (+2 : multiplication by 4) (+1 sum)

begin
    -- outputs
    result   <= std_logic_vector(Z(result'length-1 downto 0));
    finished <= '1';

    -- Modified non-restoring integer square root algorithm
    process (A,D,R,Z)

        variable R_next : signed(n+3 downto 0);

    begin
        -- initial values
        D        <= unsigned(A) & "00";
        R        <= (others => '0');
        Z        <= (others => '0');

        if (unsigned(A) = to_unsigned(0,A'length)) then

            -- output == input

        else
            for i in 0 to n-1 loop
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
            end loop;

        end if;
    end process;

end a3;
