--------------------------------------------------------------------------------
-- Módulo: projeto_top
-- Descrição: Arquivo Top-Level que integra os módulos.
--            Conecta o divisor de clock, debouncer, timer de clique, FSM e PWM.
--            Mapeia as entradas (KEY, SW) e saídas (LEDG, LEDR, GPIO) da placa.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity projeto_top is
    generic (
        TICK_COUNT_G : integer := 50000; -- Valor para gerar tick de 1ms a 50MHz
        DEBOUNCE_MS_G : integer := 20    -- Tempo de debounce de 20ms
    );

    port (
        CLOCK_50 : in  std_logic; -- Clock principal de 50MHz
        KEY      : in  std_logic_vector(3 downto 0); -- Botões (KEY(0) = controle, KEY(3) = reset)
        SW       : in  std_logic_vector(17 downto 0); -- Chaves (SW(0) = sensor de luz)
        LEDG     : out std_logic_vector(8 downto 0);  -- LEDs Verdes (LEDG(0) = Meia Luz)
        LEDR     : out std_logic_vector(17 downto 0) -- LEDs Vermelhos (LEDR(0) = Luz Total)
    );
end entity;

architecture rtl of projeto_top is
    -- Sinais internos para interconexão dos módulos
    signal rst          : std_logic;
    signal btn_raw      : std_logic;
    signal btn_clean    : std_logic;
    signal btn_clean_d  : std_logic; -- Atrasado para detecção de borda
    signal press_pulse  : std_logic;
    signal rel_pulse    : std_logic;
    signal tick_1khz    : std_logic;
    signal short_click  : std_logic;
    signal long_click   : std_logic;
    signal led_v_int    : std_logic;
    signal led_r_int    : std_logic;
    signal pwm_duty     : unsigned(7 downto 0);
    signal pwm_out      : std_logic;

begin
    -- Lógica de Reset: KEY(3) é ativo baixo na placa, invertemos para rst ativo alto
    rst <= not KEY(3);
    
    -- Lógica de Botão: KEY(0) é ativo baixo, invertemos para btn_raw ativo alto
    btn_raw <= not KEY(0);

    -- 1. Instância do Gerador de Tick (Base de Tempo)
    tick_gen_inst: entity work.tick_generator
        generic map (
            MAX_COUNT => TICK_COUNT_G
        )
        port map (
            clk       => CLOCK_50,
            rst       => rst,
            tick_1khz => tick_1khz
        );

    -- 2. Instância do Debouncer (Filtro de Ruído)
    debouncer_inst: entity work.debouncer
        generic map (
            STABLE_MS => DEBOUNCE_MS_G
        )
        port map (
            clk       => CLOCK_50,
            rst       => rst,
            tick_1khz => tick_1khz,
            btn_in    => btn_raw,
            btn_out   => btn_clean
        );

    -- Detecção de bordas no sinal limpo do botão para uso no timer
    process(CLOCK_50, rst)
    begin
        if rst = '1' then
            btn_clean_d <= '0';
        elsif rising_edge(CLOCK_50) then
            btn_clean_d <= btn_clean;
        end if;
    end process;

    -- Pulso de 1 ciclo no início (press_pulse) e fim (rel_pulse) da pressão
    press_pulse <= '1' when (btn_clean = '1' and btn_clean_d = '0') else '0';
    rel_pulse   <= '1' when (btn_clean = '0' and btn_clean_d = '1') else '0';

    -- 3. Instância do Click Timer (Diferencia curto/longo)
    click_timer_inst: entity work.click_timer
        port map (
            clk         => CLOCK_50,
            rst         => rst,
            tick_1khz   => tick_1khz,
            btn_clean   => btn_clean,
            press_pulse => press_pulse,
            rel_pulse   => rel_pulse,
            short_click => short_click,
            long_click  => long_click
        );

    -- 4. Instância da FSM (Cérebro do Sistema)
    fsm_inst: entity work.fsm_iluminacao
        port map (
            clk         => CLOCK_50,
            rst         => rst,
            sensor      => SW(0),
            short_click => short_click,
            long_click  => long_click,
            led_v       => led_v_int,
            led_r       => led_r_int
        );

    -- 5. Lógica de Brilho e Instância do PWM
    -- Define o Duty Cycle baseado no estado da FSM:
    -- OFF: 0 (0%), MEIA: 128 (50%), TOTAL: 255 (100%)
    pwm_duty <= x"FF" when led_r_int = '1' else
                x"40" when led_v_int = '1' else
                x"00";

    pwm_gen_inst: entity work.pwm_generator
        generic map (
            BITS => 8
        )
        port map (
            clk     => CLOCK_50,
            rst     => rst,
            duty    => pwm_duty,
            pwm_out => pwm_out
        );

    -- Conexão das saídas físicas
    LEDG(0) <= led_v_int; -- LED Verde (Meia Luz)
    LEDR(0) <= led_r_int; -- LED Vermelho (Luz Total)
    LEDR(17) <= pwm_out; -- LED Dimerizado Real

    -- Desliga os LEDs que não estão sendo utilizados
    LEDG(8 downto 1) <= (others => '0');
    LEDR(16 downto 1) <= (others => '0');

end architecture;