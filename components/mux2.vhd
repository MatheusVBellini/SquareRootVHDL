-- Author: Matheus Violaro Bellini

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2 is
    generic(n : integer := 32);
    port (
        din0 : in  std_logic_vector(n-1 downto 0);
        din1 : in  std_logic_vector(n-1 downto 0);
        sel  : in  std_logic;
        dout : out std_logic_vector(n-1 downto 0)
    );
end mux2;

architecture a1 of mux2 is
begin

    dout <= din0 when sel = '0' else din1;

end architecture a1;
