--------------------------------------------------------------------------------
-- Módulo: tb_click_timer
-- Descrição: Testbench para o módulo click_timer.
--            Simula pressões de botão de diferentes durações para validar a
--            detecção de cliques curtos e longos.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_click_timer is
end tb_click_timer;

architecture tb of tb_click_timer is
  -- Sinais de estímulo
  signal clk         : std_logic := '0';
  signal rst         : std_logic := '0';
  signal tick_1khz   : std_logic := '0';
  signal btn         : std_logic := '0';
  signal btn_d       : std_logic := '0';
  signal press_pulse : std_logic;
  signal rel_pulse   : std_logic;
  
  -- Sinais de observação
  signal short_click : std_logic;
  signal long_click  : std_logic;

begin
  -- Instância da Unidade Sob Teste (UUT)
  uut : entity work.click_timer
    port map
    (
      clk         => clk,
      rst         => rst,
      tick_1khz   => tick_1khz,
      btn_clean   => btn,
      press_pulse => press_pulse,
      rel_pulse   => rel_pulse,
      short_click => short_click,
      long_click  => long_click
    );

  -- Geração do Clock (50MHz -> Período de 20ns)
  process
  begin
    while true loop
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
    end loop;
  end process;

  -- Geração do Tick de 1ms
  process
  begin
    while true loop
      tick_1khz <= '0';
      wait for 999980 ns; -- Quase 1ms
      tick_1khz <= '1';
      wait for 20 ns;     -- 1 ciclo de clock
    end loop;
  end process;

  -- Lógica de detecção de borda para gerar press_pulse e rel_pulse
  process(clk)
  begin
    if rising_edge(clk) then
        btn_d <= btn;
    end if;
  end process;
  
  press_pulse <= '1' when (btn = '1' and btn_d = '0') else '0';
  rel_pulse   <= '1' when (btn = '0' and btn_d = '1') else '0';

  -- Processo de estímulos
  process
  begin
    -- Reset inicial
    rst <= '1';
    btn <= '0';
    wait for 5 ms;
    rst <= '0';
    wait for 20 ms;

    -- Caso 1: Clique Curto (120ms)
    btn <= '1';
    wait for 120 ms;
    btn <= '0';
    wait for 50 ms;

    -- Caso 2: Clique Longo (900ms)
    btn <= '1';
    wait for 900 ms;
    btn <= '0';
    wait for 50 ms;

    -- Caso 3: Ruído / Pressionamento muito curto (10ms) - Não deve gerar clique
    btn <= '1';
    wait for 10 ms;
    btn <= '0';
    wait for 50 ms;

    -- Caso 4: Outro Clique Curto (200ms)
    btn <= '1';
    wait for 200 ms;
    btn <= '0';
    wait for 50 ms;

    wait; -- Finaliza simulação
  end process;

end tb;