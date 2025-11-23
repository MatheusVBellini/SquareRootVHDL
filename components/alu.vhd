-- Author: Matheus Violaro Bellini

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    generic(n : integer := 32);
    port (
        din0 : in  unsigned(n-1 downto 0);
        din1 : in  unsigned(n-1 downto 0);
        op   : in  std_logic;                -- 0 : - | 1 : +
        dout : out unsigned(n-1 downto 0)
    );
end alu;

architecture a1 of alu is
begin

    dout <= (din0+din1) when op = '1' else (din0-din1);

end architecture a1;
