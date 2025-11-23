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
        load     : out std_logic;
        flush    : out std_logic;
        finished : out std_logic
    );
end sqrt_controller;

architecture a1 of sqrt_controller is

    type t_State is (s_WAIT, s_COMPUTE);
    signal state : t_State;

    subtype t_Iter is integer range 0 to n;
    signal iter : t_Iter;

begin

    -- Combinational wires
    state    <= s_COMPUTE when (start = '1') else s_WAIT; -- Mealy States
    finished <= '1' when (iter = n and state = s_COMPUTE) else '0';
    load     <= '1' when (state = s_WAIT) else '0';
    flush    <= '1' when (state = s_WAIT) else '0';

    -- Sequential signal control
    process (clk, reset)
    begin
        if (reset = '1') then
            iter  <= 0;
        elsif (rising_edge(clk)) then
            case state is
                when s_WAIT    => iter <= 0;
                when s_COMPUTE => if (iter <= n - 1) then iter <= iter + 1; end if;
            end case;
        end if;
    end process;

end architecture a1;
