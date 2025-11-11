-- Author: Matheus Violaro Bellini

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SQRT is
    generic(n : integer := 32);
    port (
        A           : in    std_logic_vector(2*n-1 downto 0);
        start       : in    std_logic;
        reset       : in    std_logic;
        clk         : in    std_logic;
        finished    : out   std_logic;
        result      : out   std_logic_vector(n-1 downto 0)
    );
end SQRT;
