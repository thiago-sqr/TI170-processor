module answer_writer(
    input wire clock,
    input wire reset,
    input wire [7:0] data_in[0:127],    // Dados de entrada para escrever no arquivo
    input wire write_enable,      // Sinal para habilitar a escrita
    input reg  answer_size       // indica a quantidade de linhas a serem escritas
    output reg done             // Indica quando a escrita está concluída
    
);
    // Identificador do arquivo
    integer file_id;

    // Inicialização: abrir o arquivo para escrita
    initial begin
        file_id = $fopen("answer.bin", "wb"); // "wb" para escrita binária
        if (file_id == 0) begin
            $display("Erro: Não foi possível abrir o arquivo 'answer.bin'.");
            $stop;
        end
        done = 0; // Especifica que a operação ainda não foi concluída
    end

    // Sempre que houver um pulso de clock, verificar condições de escrita
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            done <= 0;  // Reiniciar estado de finalização
        end else if (write_enable) begin
            integer i
            for(i = 0; i < PR; i = i + 1) begin
                $fwrite(file_id, "%c", data_in[i]); // Escreve os dados no arquivo como binário
                $display("Dado escrito: %0h", data_in); // Mensagem para depuração
            end
        end
    end

    // Finalização: fechar o arquivo
    final begin
        $fclose(file_id); // Garante que o arquivo seja fechado corretamente
        done <= 1;        // Marca o processo como concluído
        $display("Arquivo 'answer.bin' salvo com sucesso.");
    end
endmodule
