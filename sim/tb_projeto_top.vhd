--------------------------------------------------------------------------------
-- Módulo: tb_projeto_top
-- Descrição: Testbench de nível de sistema (Top-Level).
--            Integra todos os módulos e simula o comportamento da placa DE2-115.
--            Utiliza parâmetros genéricos reduzidos para acelerar a simulação.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_projeto_top is
end entity;

architecture tb of tb_projeto_top is
  -- Sinais para conectar às portas do projeto_top
    signal CLOCK_50 : std_logic := '0';
    signal KEY      : std_logic_vector(3 downto 0) := "1111"; -- Ativo baixo (1111 = solto)
    signal SW       : std_logic_vector(17 downto 0) := (others => '0');
    signal LEDG     : std_logic_vector(8 downto 0);
    signal LEDR     : std_logic_vector(17 downto 0);

    constant clk_period : time := 20 ns;
begin

    -- Instância do Top-Level com parâmetros de tempo reduzidos para simulação
    uut: entity work.projeto_top
        generic map (
            TICK_COUNT_G => 10,  -- 1ms simulado a cada 10 ciclos (em vez de 50.000)
            DEBOUNCE_MS_G => 2   -- Debounce de 2ms para rapidez nos testes
        )

        port map (
            CLOCK_50 => CLOCK_50,
            KEY      => KEY,
            SW       => SW,
            LEDG     => LEDG,
            LEDR     => LEDR
        );

    -- Geração do Clock de 50MHz
    clk_process: process
    begin
        CLOCK_50 <= '0';
        wait for clk_period/2;
        CLOCK_50 <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- 1. Reset do sistema (KEY(3) é o reset ativo baixo)
        KEY(3) <= '0'; 
        wait for 100 ns;
        KEY(3) <= '1'; 
        wait for 100 ns;

        -- Teste 1: Ativação Automática via Sensor de Luz
        SW(0) <= '1'; -- Simula ambiente escuro
        wait for 1 us; -- Deve ligar LEDR(0) (Luz Total)

        -- Teste 2: Clique Longo Manual (Sobrescrita para Meia Luz)
        -- Pressiona KEY(0) (ativo baixo)
        KEY(0) <= '0';
        -- Espera tempo suficiente para clique longo (>800ms simulados)
        -- No TB: 800 * 10 * 20ns = 160us.
        wait for 200 us;
        KEY(0) <= '1'; -- Solta botão
        wait for 50 us; -- LEDG(0) deve ligar e LEDR(0) desligar

        -- Teste 3: Clique Curto Manual (Sobrescrita para OFF)
        KEY(0) <= '0';

        -- Espera tempo para clique curto (>30ms e <800ms simulados)
        wait for 40 us;
        KEY(0) <= '1';
        wait for 50 us; -- Todos os LEDs devem apagar

        -- Teste 4: Sensor de Luz detecta ambiente claro
        SW(0) <= '0';
        wait for 1 us;

        -- Teste 5: Acionamento Manual a partir do estado OFF
        KEY(0) <= '0';
        wait for 10 us;
        KEY(0) <= '1';
        wait for 50 us; -- Deve ligar LEDR(0) novamente

        wait; -- Fim dos testes
    end process;
end architecture;