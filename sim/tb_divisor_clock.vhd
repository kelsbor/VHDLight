library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 1. ENTIDADE VAZIA
-- Um testbench não se conecta a nada externo, então a entidade é vazia.
entity tb_divisor_clock is
end tb_divisor_clock;

architecture simulacao of tb_divisor_clock is

    -- 2. DECLARAÇÃO DO COMPONENTE
    -- Avisamos ao testbench que o seu módulo existe e como são os pinos dele.
    component divisor_clock is
        generic ( MAX_COUNT : integer );
        port (
            clk_in  : in  std_logic;
            rst     : in  std_logic;
            clk_out : out std_logic
        );
    end component;

    -- 3. SINAIS INTERNOS (Os "fios" da protoboard virtual)
    signal tb_clk_in  : std_logic := '0';
    signal tb_rst     : std_logic := '0';
    signal tb_clk_out : std_logic;

    -- 4. CONFIGURAÇÃO DO TEMPO
    -- 50 MHz = 1 segundo / 50.000.000 = 20 nanosegundos por ciclo.
    constant periodo_clock : time := 20 ns;

    begin

    -- 5. INSTANCIAÇÃO (Colocando o chip na protoboard virtual)
    -- O "UUT" significa Unit Under Test (Unidade Sob Teste).
    UUT: divisor_clock
        generic map (
            MAX_COUNT => 5 -- Mantemos o valor baixo para simular rápido
        )
        port map (
            clk_in  => tb_clk_in,
            rst     => tb_rst,
            clk_out => tb_clk_out
        );

    -- 6. GERADOR DE CLOCK INFINITO
    -- Fica invertendo o sinal a cada 10ns, criando um ciclo completo de 20ns (50 MHz).
    processo_clock: process
    begin
        tb_clk_in <= '0';
        wait for periodo_clock / 2;
        tb_clk_in <= '1';
        wait for periodo_clock / 2;
    end process;

    -- 7. GERADOR DE ESTÍMULOS (Os apertos de botão)
    processo_estimulos: process
    begin
        -- Estado inicial: Aplica um reset rápido para garantir que o contador comece zerado
        tb_rst <= '1';
        wait for 50 ns;
        tb_rst <= '0';

        -- A partir daqui, o clock está batendo livremente.
        -- Vamos esperar tempo suficiente para ver o clk_out mudar de estado algumas vezes.
        -- Como MAX_COUNT = 5, ele deve inverter a saída a cada 5 clocks (100 ns).
        wait for 500 ns; 

        -- Simula um usuário apertando o reset no meio do funcionamento
        tb_rst <= '1';
        wait for 30 ns;
        tb_rst <= '0';

        -- Espera mais um pouco para observar o comportamento pós-reset
        wait for 300 ns;

        -- Encerra a simulação (evita que o gerador de clock rode para sempre)
    end process;

end simulacao;