-- Author: Matheus Violaro Bellini

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sqrt_datapath is
    generic(n : integer := 32);
    port (
        din    : in  unsigned(2*n-1 downto 0);
        clk    : in  std_logic;
        reset  : in  std_logic;
        load   : in  std_logic;
        enable : in  std_logic;
        dout   : out unsigned(n-1 downto 0)
    );
end sqrt_datapath;

architecture a1 of sqrt_datapath is

    signal Q_out             : std_logic_vector(n-1 downto 0);
    signal R_in              : std_logic_vector(n+1 downto 0);
    signal R_out             : std_logic_vector(n+1 downto 0);
    signal even_in, even_out : std_logic_vector(n-1 downto 0);
    signal odd_in , odd_out  : std_logic_vector(n-1 downto 0);

    -- intermediate signals
    signal alu_in_0          : unsigned(n+1 downto 0);
    signal alu_in_1          : unsigned(n+1 downto 0);
    signal alu_out           : unsigned(n+1 downto 0);
    signal not_r             : std_logic;

    -- outputs
    signal mux_output        : std_logic_vector(n-1 downto 0);
    signal output            : std_logic_vector(n-1 downto 0);

begin

    -- D : even row generation
    GEN_EVEN : for i in 0 to n-1 generate

        GEN_FIRST : if i = 0 generate
            MUX_INST : entity work.mux2(a1)
                generic map (n => 1)
                port map (
                    din0 => (others => '0'),
                    din1 => std_logic_vector(din(2*i downto 2*i)),
                    sel  => load,
                    dout => even_in(i downto i)
                );
        end generate GEN_FIRST;

        GEN_OTHERS : if i > 0 generate
            MUX_INST : entity work.mux2(a1)
                generic map (n => 1)
                port map (
                    din0 => std_logic_vector(even_out(i-1 downto i-1)),
                    din1 => std_logic_vector(din(2*i downto 2*i)),
                    sel  => load,
                    dout => even_in(i downto i)
                );
        end generate GEN_OTHERS;

        FF_INST : entity work.shift_ff(a1)
            generic map (n => 1)
            port map (
                din   => even_in(i),  -- takes input from Mux
                clk   => clk,
                reset => reset,
                dout  => even_out(i downto i)  -- output becomes Q state
            );
    end generate GEN_EVEN;

    -- D : odd row generation
    GEN_ODD : for i in 0 to n-1 generate

        GEN_FIRST : if i = 0 generate
            MUX_INST : entity work.mux2(a1)
                generic map (n => 1)
                port map (
                    din0 => (others => '0'),
                    din1 => std_logic_vector(din(2*i + 1 downto 2*i + 1)),
                    sel  => load,
                    dout => odd_in(i downto i)
                );
        end generate GEN_FIRST;

        GEN_OTHERS : if i > 0 generate
            MUX_INST : entity work.mux2(a1)
                generic map (n => 1)
                port map (
                    din0 => std_logic_vector(odd_out(i-1 downto i-1)),
                    din1 => std_logic_vector(din(2*i + 1 downto 2*i + 1)),
                    sel  => load,
                    dout => odd_in(i downto i)
                );
        end generate GEN_OTHERS;

        FF_INST : entity work.shift_ff(a1)
            generic map (n => 1)
            port map (
                din   => odd_in(i),
                clk   => clk,
                reset => reset,
                dout  => odd_out(i downto i)
            );
    end generate GEN_ODD;

    -- Q
    not_r <= not R_out(n+1);
    Q_INST : entity work.shift_ff(a1)
        generic map (n => n)
        port map (
            din   => not_r,
            clk   => clk,
            reset => reset,
            dout  => Q_out
        );

    -- ALU
    alu_in_0 <= unsigned(R_out(n-1 downto 0) & odd_out(n-1) & even_out(n-1));
    alu_in_1 <= unsigned(Q_out & R_out(n+1) & '1');
    R_in <= std_logic_vector(alu_out);
    ALU_INST : entity work.alu(a1)
        generic map (n => n+2)
        port map (
            din0 => alu_in_0,
            din1 => alu_in_1,
            op   => R_out(n+1),
            dout => alu_out
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

    -- output register
    OUTPUT_MUX : entity work.mux2(a1)
        generic map (n => n)
        port map (
            din0 => output,
            din1 => Q_out,
            sel  => enable,
            dout => mux_output
        );

    OUTPUT_REG : entity work.dff(a1)
        generic map (n => n)
        port map (
            din   => mux_output,
            clk   => clk,
            reset => reset,
            dout  => output
        );

    dout <= unsigned(output);

end architecture a1;
