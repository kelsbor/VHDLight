library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Define pinos de entrada e saída do seu chip.
entity divisor_clock is
    generic (
        -- Parâmetro configurável. Na placa real (50MHz para 1Hz), seria 25.000.000.
        MAX_COUNT : integer := 5 
    );
    port (
        clk_in  : in  std_logic; -- Clock rápido (50 MHz)
        rst     : in  std_logic; -- Botão de reset para zerar o contador
        clk_out : out std_logic  -- Clock lento gerado
    );
end divisor_clock;

architecture Comportamental of divisor_clock is
    -- Sinais internos
    signal contador : integer range 0 to MAX_COUNT := 0;
    signal estado_clk : std_logic := '0';

begin
    -- PROCESSO
    -- Quando 'clk_in' ou 'rst' mudam de valor:
    process(clk_in, rst)
    begin
        -- Reset assíncrono: se o botão de reset for apertado, zera tudo na hora.
        if rst = '1' then
            contador <= 0;
            estado_clk <= '0';
            
        -- Identificador de Borda de Subida: Acontece a cada "tick" do relógio principal.
        elsif rising_edge(clk_in) then
            
            if contador = MAX_COUNT - 1 then
                estado_clk <= not estado_clk; -- Inverte o sinal (de 0 vai pra 1, de 1 vai pra 0)
                contador <= 0;                -- Reinicia a contagem
            else
                contador <= contador + 1;     -- Apenas soma 1
            end if;
            
        end if;
    end process;

    -- Conecta o fio interno (estado_clk) ao pino de saída físico (clk_out)
    clk_out <= estado_clk;

end Comportamental;