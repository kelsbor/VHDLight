--------------------------------------------------------------------------------
-- Módulo: click_timer
-- Descrição: Identifica cliques curtos e longos baseados no tempo de pressão.
--            Clique Longo: Pressionado por >= 800ms.
--            Clique Curto: Pressionado entre 30ms e 800ms.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity click_timer is
    port (
        clk         : in  std_logic; -- Clock de 50MHz
        rst         : in  std_logic; -- Reset ativo alto
        tick_1khz   : in  std_logic; -- Pulso de 1ms
        btn_clean   : in  std_logic; -- Botão filtrado (ativo alto)
        press_pulse : in  std_logic; -- Pulso de início de pressão
        rel_pulse   : in  std_logic; -- Pulso de soltura
        short_click : out std_logic; -- Saída de clique curto (1 ciclo)
        long_click  : out std_logic  -- Saída de clique longo (1 ciclo)
    );
    
end entity;

architecture rtl of click_timer is
    constant LONG_MS      : integer := 800; -- Limiar para clique longo
    constant SHORT_MIN_MS : integer := 30;  -- Limiar mínimo para evitar ruído

    signal hold_cnt       : unsigned(15 downto 0) := (others => '0'); -- Contador de ms
    signal long_sent      : std_logic := '0'; -- Garante um único pulso por pressão
    signal short_r        : std_logic := '0'; -- Registrador para clique curto
    signal long_r         : std_logic := '0'; -- Registrador para clique longo
    
begin
    short_click <= short_r;
    long_click  <= long_r;

    process(clk, rst)
    begin
        if rst = '1' then
            hold_cnt  <= (others => '0');
            long_sent <= '0';
            short_r   <= '0';
            long_r    <= '0';
        elsif rising_edge(clk) then
            -- Reset dos pulsos de saída (duram 1 ciclo)
            short_r <= '0';
            long_r  <= '0';

            -- Reinicia contagem ao pressionar
            if press_pulse = '1' then
                hold_cnt  <= (others => '0');
                long_sent <= '0';
            end if;

            -- Incrementa contador enquanto pressionado (base 1ms)
            if tick_1khz = '1' and btn_clean = '1' then
                hold_cnt <= hold_cnt + 1;

                -- Detecta clique longo durante a pressão
                if long_sent = '0' and to_integer(hold_cnt) >= LONG_MS then
                    long_r    <= '1';
                    long_sent <= '1';
                end if;
            end if;

            -- Verifica clique curto ao soltar o botão
            if rel_pulse = '1' then
                if long_sent = '0' then
                    if to_integer(hold_cnt) >= SHORT_MIN_MS and to_integer(hold_cnt) < LONG_MS then
                        short_r <= '1';
                    end if;
                end if;
                hold_cnt  <= (others => '0');
                long_sent <= '0';
            end if;
        end if;
    end process;
end architecture;