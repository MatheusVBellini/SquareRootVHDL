-- Author: Matheus Violaro Bellini

--
-- A3 surrounded by registers to test timing
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity A3_TIMING is
    generic(n : integer := 32);
    port (
        A       : in    std_logic_vector(2*n-1 downto 0);
        clk     : in    std_logic;
        reset   : in    std_logic;
        result  : out   std_logic_vector(n-1 downto 0)
    );
end A3_TIMING;

architecture a1 of A3_TIMING is

    -- Components
    component SQRT_comb is
        generic(n : integer := 32);
        port (
            A           : in    std_logic_vector(2*n-1 downto 0);
            result      : out   std_logic_vector(n-1 downto 0)
        );
    end component SQRT_comb;

    -- Signals
    signal dff_in   : std_logic_vector(2*n-1 downto 0);
    signal dff_out  : std_logic_vector(n-1 downto 0);

begin

    -- DUT instantiation
    DUT : SQRT_comb
    generic map (n => n)
    port map(
        A        => dff_in,
        result   => dff_out
    );

    process(reset, clk)
    begin
        if (reset = '1') then
            dff_in  <= (others => '0');
            result  <= (others => '0');
        elsif (rising_edge(clk)) then
            dff_in  <= A;
            result  <= dff_out;
        end if;
    end process;

end architecture a1;