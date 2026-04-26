--------------------------------------------------------------------------------
-- Módulo: tb_fsm_iluminacao
-- Descrição: Testbench para a Máquina de Estados (FSM) de iluminação.
--            Valida as transições automáticas pelo sensor e as prioridades
--            do controle manual (override).
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_fsm_iluminacao is
end entity;

architecture tb of tb_fsm_iluminacao is
    -- Sinais de interface
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal sensor      : std_logic := '0';
    signal short_click : std_logic := '0';
    signal long_click  : std_logic := '0';
    signal led_v       : std_logic;
    signal led_r       : std_logic;

    constant clk_period : time := 20 ns;
begin
    -- Instância da FSM
    uut: entity work.fsm_iluminacao
        port map (
            clk         => clk,
            rst         => rst,
            sensor      => sensor,
            short_click => short_click,
            long_click  => long_click,
            led_v       => led_v,
            led_r       => led_r
        );

    -- Geração do Clock
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Processo de estímulos para validar a lógica de controle
    stim_proc: process
    begin
        -- Estado inicial e Reset
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Teste 1: Transição Automática - Sensor detecta escuro (0 -> 1)
        sensor <= '1';
        wait for 100 ns; -- Deve ir para ST_TOTAL (led_r = '1')

        -- Teste 2: Sobrescrita Manual (Override) - Clique longo para Meia Luz
        long_click <= '1';
        wait for clk_period;
        long_click <= '0';
        wait for 100 ns; -- Deve ir para ST_MEIA (led_v = '1'), mesmo com sensor em '1'

        -- Teste 3: Sobrescrita Manual - Clique curto para desligar
        short_click <= '1';
        wait for clk_period;
        short_click <= '0';
        wait for 100 ns; -- Deve ir para ST_OFF

        -- Teste 4: Reset do Override - Sensor detecta claro (1 -> 0)
        sensor <= '0';
        wait for 100 ns;

        -- Teste 5: Nova Transição Automática - Sensor detecta escuro novamente
        sensor <= '1';
        wait for 100 ns; -- Deve ir para ST_TOTAL

        -- Teste 6: Clique curto a partir de ST_TOTAL -> ST_OFF
        short_click <= '1';
        wait for clk_period;
        short_click <= '0';
        wait for 100 ns;

        -- Teste 7: Acionamento Manual a partir de OFF (Sem mudança no sensor)
        short_click <= '1';
        wait for clk_period;
        short_click <= '0';
        wait for 100 ns; -- Deve ir para ST_TOTAL

        wait;
    end process;
end architecture;