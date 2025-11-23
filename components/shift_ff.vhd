-- Author: Matheus Violaro Bellini

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift_ff is
    generic(n : integer := 32);
    port (
        din     : in    std_logic;
        clk     : in    std_logic;
        reset   : in    std_logic;
        dout    : out   std_logic_vector(n-1 downto 0)
    );
end shift_ff;

architecture a1 of shift_ff is

    signal reg : std_logic_vector(n-1 downto 0);

begin

    process (clk, reset)
    begin
        if (reset = '1') then
            reg <= (others => '0');
        elsif (rising_edge(clk)) then
            reg <= reg(n-2 downto 0) & din;
        end if;
    end process;

    dout <= reg;

end architecture a1;
