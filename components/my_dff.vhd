-- Author: Matheus Violaro Bellini

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity my_dff is
    generic(n : integer := 32);
    port (
        din   : in  std_logic_vector(n-1 downto 0);
        clk   : in  std_logic;
        reset : in  std_logic;
        dout  : out std_logic_vector(n-1 downto 0)
    );
end my_dff;

architecture a1 of my_dff is
begin

    process(clk, reset)
    begin
        if reset = '1' then
            dout <= (others => '0');
        elsif rising_edge(clk) then
            dout <= din;
        end if;
    end process;

end architecture a1;
