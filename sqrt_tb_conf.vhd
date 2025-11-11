use work.all;

configuration SQRT_TB_CONF of SQRT_TB is
    for a1
        for DUT : SQRT
            use entity work.SQRT(a2);
        end for;
    end for;
end SQRT_TB_CONF;
