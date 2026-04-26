--------------------------------------------------------------------------------
-- Módulo: tick_generator
-- Descrição: Atua como um divisor de clock para gerar um pulso de 1ms (tick).
--            Utilizado como base de tempo para debounce e temporização de cliques.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tick_generator is
    generic (
        MAX_COUNT : integer := 50000 -- 50MHz / 1000 = 50.000 para obter 1kHz (1ms)
    );
    
    port (
        clk       : in  std_logic; -- Clock de entrada (ex: 50MHz)
        rst       : in  std_logic; -- Reset ativo alto
        tick_1khz : out std_logic  -- Pulso de saída que dura 1 ciclo de clock a cada 1ms
    );
end entity;

architecture rtl of tick_generator is
    -- Contador para divisão de frequência
    signal counter : integer range 0 to MAX_COUNT - 1 := 0;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            tick_1khz <= '0';
        elsif rising_edge(clk) then
            -- Valor padrão do tick é '0'
            tick_1khz <= '0';
            
            -- Se atingir o valor máximo, reseta o contador e sinaliza o tick
            if counter = MAX_COUNT - 1 then
                counter <= 0;
                tick_1khz <= '1';
            else
                -- Caso contrário, apenas incrementa
                counter <= counter + 1;
            end if;
        end if;
    end process;
end architecture;