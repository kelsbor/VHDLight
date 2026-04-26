--------------------------------------------------------------------------------
-- Módulo: debouncer
-- Descrição: Remove o ruído mecânico (bouncing) dos botões.
--            O sinal de saída só muda se a entrada permanecer estável por um
--            tempo determinado (STABLE_MS).
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
    generic (
        STABLE_MS : integer := 10 -- Tempo de estabilidade em milissegundos
    );
    port (
        clk       : in  std_logic; -- Clock de 50MHz
        rst       : in  std_logic; -- Reset 
        tick_1khz : in  std_logic; -- Pulso de 1ms
        btn_in    : in  std_logic; -- Entrada bruta do botão
        btn_out   : out std_logic  -- Saída filtrada (limpa)
    );
end entity;

architecture rtl of debouncer is
    -- Contador para medir o tempo de estabilidade
    signal count : integer range 0 to STABLE_MS := 0;

    -- Estado interno atual da saída
    signal state : std_logic := '0';

    -- Sinais para sincronização (evitar metaestabilidade)
    signal sync_0, sync_1 : std_logic := '0';
    
begin
    -- Atribui o estado estável à saída
    btn_out <= state;

    process(clk, rst)
    begin
        if rst = '1' then
            sync_0 <= '0';
            sync_1 <= '0';
            count  <= 0;
            state  <= '0';
        elsif rising_edge(clk) then
            -- Estágios de sincronização para a entrada assíncrona
            sync_0 <= btn_in;
            sync_1 <= sync_0;

            -- A lógica de debounce opera na base de tempo de 1ms
            if tick_1khz = '1' then
                -- Se a entrada atual for diferente do estado estável
                if sync_1 /= state then
                    -- Incrementa contador; se atingir o limite, atualiza o estado
                    if count = STABLE_MS - 1 then
                        state <= sync_1;
                        count <= 0;
                    else
                        count <= count + 1;
                    end if;
                else
                    -- Se a entrada voltou ao estado estável, reseta o contador
                    count <= 0;
                end if;
            end if;
        end if;
    end process;
end architecture;