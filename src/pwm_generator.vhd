--------------------------------------------------------------------------------
-- Módulo: pwm_generator
-- Descrição: Gera um sinal PWM (Pulse Width Modulation) para controle de brilho.
--            A largura do pulso é proporcional ao valor de 'duty'.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator is
    generic (
        BITS : integer := 8 -- Resolução do PWM (2^8 = 256 níveis)
    );
    port (
        clk     : in  std_logic; -- Clock de 50MHz
        rst     : in  std_logic; -- Reset ativo alto
        duty    : in  unsigned(BITS-1 downto 0); -- Valor do ciclo de trabalho (0 a 255)
        pwm_out : out std_logic  -- Saída do sinal PWM
    );
end entity;

architecture rtl of pwm_generator is
    -- Contador interno que define o período do PWM
    signal counter : unsigned(BITS-1 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
            pwm_out <= '0';
        elsif rising_edge(clk) then
            -- Incrementa o contador continuamente
            counter <= counter + 1;
            
            -- Se o contador for menor que o duty cycle desejado, a saída é '1'
            if counter < duty then
                pwm_out <= '1';
            else
                -- Caso contrário, a saída é '0'
                pwm_out <= '0';
            end if;
        end if;
    end process;
end architecture;