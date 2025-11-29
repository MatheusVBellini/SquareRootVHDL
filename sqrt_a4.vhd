-- Author: Matheus Violaro Bellini

--
-- This architecture implements a modified non-restoring integer
-- square root algorithm to calculate the integer square-root of a number.
--
-- This implementation uses a pipeline.
--
architecture a4 of SQRT is

type D_pipeline is array (0 to n) of unsigned(2*n+1 downto 0);
type Z_pipeline is array (0 to n) of unsigned(n+2 downto 0);
type R_pipeline is array (0 to n) of signed(n+3 downto 0);

signal D     : D_pipeline := (others => (others => '0'));
signal Z     : Z_pipeline := (others => (others => '0'));
signal R     : R_pipeline := (others => (others => '0'));
signal valid : std_logic_vector(n+1 downto 0); -- n+1 because the pipeline needs 1 iteration for input loading

begin
    -- output
    result   <= std_logic_vector(Z(n)(result'length-1 downto 0));
    finished <= valid(n+1);

    -- Modified non-restoring integer square root algorithm
    process (clk, reset)

        variable R_next : R_pipeline;

    begin
        if (reset = '1') then

            valid <= (others => '0');
            D(0)  <= (others => '0');
            R(0)  <= (others => '0');
            Z(0)  <= (others => '0');

        elsif (rising_edge(clk)) then
            -- valid pipeline update
            valid <= valid(n downto 0) & '1';

            -- initial values
            D(0) <= unsigned(A) & "00";
            R(0) <= (others => '0');
            Z(0) <= (others => '0');

            -- algorithm
            for i in n downto 1 loop
                -- update R
                if (R(i-1) >= to_signed(0,R(i-1)'length)) then
                    R_next(i-1) := shift_left(R(i-1),2)
                                 + to_signed(to_integer(D(i-1)(D(i-1)'high downto D(i-1)'high-1)),R(i-1)'length)
                                 - resize(signed(shift_left(Z(i-1),2)),R(i-1)'length)
                                 - 1;
                else
                    R_next(i-1) := shift_left(R(i-1),2)
                                 + to_signed(to_integer(D(i-1)(D(i-1)'high downto D(i-1)'high-1)),R(i-1)'length)
                                 + resize(signed(shift_left(Z(i-1),2)),R(i-1)'length)
                                 + 3;
                end if;

                -- update Z
                if (R_next(i-1) >= 0) then
                    Z(i) <= shift_left(Z(i-1),1) + 1;
                else
                    Z(i) <= shift_left(Z(i-1),1);
                end if;

                D(i) <= shift_left(D(i-1),2);
                R(i) <= R_next(i-1);
            end loop;

        end if;
    end process;
end a4;
