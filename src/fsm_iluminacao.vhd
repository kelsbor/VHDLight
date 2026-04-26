--------------------------------------------------------------------------------
-- Módulo: fsm_iluminacao
-- Descrição: Máquina de Estados Finita (FSM) que controla o nível de iluminação.
--            Gerencia transições automáticas via sensor de luz e controle manual
--            via botões, com lógica de sobrescrita (override).
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fsm_iluminacao is
    port (
        clk         : in  std_logic; -- Clock de 50MHz
        rst         : in  std_logic; -- Reset ativo alto
        sensor      : in  std_logic; -- Sensor de luz (0=Claro, 1=Escuro)
        short_click : in  std_logic; -- Pulso de clique curto
        long_click  : in  std_logic; -- Pulso de clique longo
        led_v       : out std_logic; -- Indica estado "Meia Luz" (LED Verde)
        led_r       : out std_logic  -- Indica estado "Luz Total" (LED Vermelho)
    );
end entity;

architecture rtl of fsm_iluminacao is
    -- Estados da iluminação
    type state_type is (ST_OFF, ST_MEIA, ST_TOTAL);
    signal state_reg, state_next : state_type;
    
    -- Sinais para detecção de mudança no sensor e controle de override
    signal sensor_d : std_logic; -- Sensor atrasado para detectar bordas
    signal manual_override : std_logic := '0'; -- Trava o controle manual
begin

    -- Processo Sequencial: Atualização de estado e lógica de override
    process(clk, rst)
    begin
        if rst = '1' then
            state_reg <= ST_OFF;
            sensor_d  <= '0';
            manual_override <= '0';
        elsif rising_edge(clk) then
            state_reg <= state_next;
            sensor_d  <= sensor;
            
            -- Se o sensor mudar de estado (ex: anoiteceu/amanheceu), limpa o override manual
            if sensor /= sensor_d then
                manual_override <= '0';
            -- Se houver interação manual, ativa o override para ignorar o sensor até a próxima mudança
            elsif (short_click = '1' or long_click = '1') then
                manual_override <= '1';
            end if;
        end if;
    end process;

    -- Processo Combinacional: Lógica de transição de estados
    process(state_reg, sensor, sensor_d, short_click, long_click, manual_override)
    begin
        state_next <= state_reg;

        -- Prioridade 1: Transições automáticas pelo sensor (se não houver override)
        if sensor = '1' and sensor_d = '0' then
            state_next <= ST_TOTAL; -- Escureceu: Liga luz total
        elsif sensor = '0' and sensor_d = '1' then
            state_next <= ST_OFF;   -- Clareou: Desliga tudo
        else
            -- Prioridade 2: Controle manual pelos botões
            case state_reg is
                when ST_OFF =>
                    if short_click = '1' then
                        state_next <= ST_TOTAL; -- Curto: Liga total
                    elsif long_click = '1' then
                        state_next <= ST_MEIA;  -- Longo: Liga meia luz
                    end if;
                
                when ST_TOTAL =>
                    if long_click = '1' then
                        state_next <= ST_MEIA;  -- Longo: Diminui para meia luz
                    elsif short_click = '1' then
                        state_next <= ST_OFF;   -- Curto: Desliga
                    end if;

                when ST_MEIA =>
                    if short_click = '1' then
                        state_next <= ST_OFF;   -- Curto: Desliga
                    elsif long_click = '1' then
                        state_next <= ST_TOTAL; -- Longo: Aumenta para total
                    end if;
            end case;
        end if;
    end process;

    -- Saídas baseadas no estado atual
    led_v <= '1' when state_reg = ST_MEIA else '0';
    led_r <= '1' when state_reg = ST_TOTAL else '0';

end architecture;