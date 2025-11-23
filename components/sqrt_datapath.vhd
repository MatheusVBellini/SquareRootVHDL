-- Author: Matheus Violaro Bellini

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sqrt_datapath is
    generic(n : integer := 32);
    port (
        din   : in  unsigned(2*n-1 downto 0);
        clk   : in  std_logic;
        reset : in  std_logic;
        load  : in  std_logic;
        dout  : out unsigned(n-1 downto 0)
    );
end sqrt_datapath;

architecture a1 of sqrt_datapath is

    signal Q_out             : std_logic_vector(n-1 downto 0);
    signal R_in              : std_logic_vector(n+1 downto 0);
    signal R_out             : std_logic_vector(n+1 downto 0);
    signal even_in, even_out : std_logic_vector(n-1 downto 0);
    signal odd_in , odd_out  : std_logic_vector(n-1 downto 0);

begin

    -- D : even row generation
    GEN_EVEN: for i in 0 to n-1 generate
        MUX_INST : entity work.mux2(a1)
            generic map (n => 1)
            port map (
                -- Bit 0 pulls in '0' (start of chain). Others pull from previous output.
                din0 => '0' when (i = 0) else even_out(i-1),
                -- Take the specific bit from the input vector
                din1 => std_logic(din(2*i)),
                sel  => load,
                dout => even_in(i) -- output goes to the Flip-Flop Input
            );

        FF_INST : entity work.shift_ff(a1)
            generic map (n => 1)
            port map (
                din   => even_in(i),  -- takes input from Mux
                clk   => clk,
                reset => reset,
                dout  => even_out(i)  -- output becomes Q state
            );
    end generate GEN_EVEN;

    -- D : odd row generation
    GEN_ODD: for i in 0 to n-1 generate
        MUX_INST : entity work.mux2(a1)
            generic map (n => 1)
            port map (
            -- Bit 0 pulls in '0' (start of chain). Others pull from previous output.
                din0 => '0' when (i = 0) else odd_out(i-1),
                din1 => std_logic(din(2*i + 1)),
                sel  => load,
                dout => odd_in(i)
            );

        FF_INST : entity work.shift_ff(a1)
            generic map (n => 1)
            port map (
                din   => odd_in(i),
                clk   => clk,
                reset => reset,
                dout  => odd_out(i)
            );
    end generate GEN_ODD;

    -- Q
    Q_INST : entity work.shift_ff(a1)
        generic map (n => n)
        port map (
            din   => not R_out(n+1),
            clk   => clk,
            reset => reset,
            dout  => Q_out
        );

    -- ALU
    ALU_INST : entity work.alu(a1)
        generic map (n => n+2)
        port map (
            din0 => unsigned(R_out(n-1 downto 0) & odd_out(n-1) & even_out(n-1)),
            din1 => unsigned(Q_out & R_out(n+1) & '1'),
            op   => R_out(n+1),
            dout => unsigned(R_in)
        );

    -- R
    DFF_INST : entity work.dff(a1)
        generic map (n => n+2)
        port map (
            din   => R_in,
            clk   => clk,
            reset => reset,
            dout  => R_out
        );

    -- Signal assignments
    dout <= unsigned(Q_out);


end architecture a1;
