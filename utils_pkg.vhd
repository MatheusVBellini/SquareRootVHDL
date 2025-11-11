library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utils_pkg is

    -- Function to compute bits needed to represent N values
    function bits_needed(n : integer) return natural;

end package utils_pkg;
