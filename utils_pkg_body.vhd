package body utils_pkg is

    function bits_needed(n : integer) return natural is
        variable w : natural := 0;
        variable x : natural := n - 1;
    begin
        while x > 0 loop
            x := x / 2;
            w := w + 1;
        end loop;
        if w = 0 then
            w := 1;
        end if;
        return w;
    end function;

end package body utils_pkg;
