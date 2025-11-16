use work.all;

configuration SQRT_TB_CONF of SQRT_TB is
    for arq_seq
        for DUT : SQRT
            use entity work.SQRT(a1);
        end for;
    end for;
end SQRT_TB_CONF;
