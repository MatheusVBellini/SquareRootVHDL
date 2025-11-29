-- Author: Matheus Violaro Bellini

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sqrt_controller is
    generic(n : integer := 32);
    port (
        start    : in  std_logic;
        clk      : in  std_logic;
        reset    : in  std_logic;
        flush    : out std_logic;
        load     : out std_logic;
        store    : out std_logic;
        finished : out std_logic
    );
end sqrt_controller;

architecture a1 of sqrt_controller is

    type t_State is (s_WAIT, s_COMPUTE, s_FINISHED);
    signal state : t_State;

    subtype t_Iter is integer range 0 to n;
    signal iter : t_Iter;

begin

    -- Sequential signal control
    process (clk, reset)
    begin
        if (reset = '1') then
            iter     <= 1;
            load     <= '0';
            flush    <= '1';
            store    <= '0';
            finished <= '0';
        elsif (rising_edge(clk)) then
            case state is

                -- WAIT: do nothing and wait for assignment
                when s_WAIT =>
                    iter     <= 1;
                    load     <= '1';
                    flush    <= '1';
                    store    <= '0';
                    finished <= '0';

                    if (start = '1') then
                        flush <= '0';
                        load  <= '0';
                        state <= s_COMPUTE;
                    end if;

                -- COMPUTE: apply iterations
                when s_COMPUTE =>
                    if (start = '0') then
                        state <= s_WAIT;
                    elsif (iter <= n - 1) then
                        iter <= iter + 1;
                    else
                        store <= '1';
                        state <= s_FINISHED;
                    end if;

                -- FINISHED: provide the result at the output tap
                when s_FINISHED =>
                    store <= '0';
                    finished <= '1';
                    if (start = '0') then
                        state    <= s_WAIT;
                        finished <= '0';
                    end if;

            end case;
        end if;
    end process;

end architecture a1;
