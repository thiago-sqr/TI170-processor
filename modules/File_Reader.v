module file_reader(
    input wire clock,
    input wire reset,
    output reg [7:0] data_out,   // Dados lidos do "arquivo"
    output reg data_valid        // Sinaliza que há dado válido
);
    // Memória simulando um arquivo externo
    reg [7:0] file_memory [0:31]; // Arquivo com 32 linhas (ajustável)
    reg [4:0] line_counter;       // Contador de linhas do arquivo

    // Inicializando o "arquivo" com dados binários
    initial begin
      $readmemb("arquivobinario.bin", file_memory); // Lê o arquivo binário
        line_counter = 0;
        data_valid = 0;
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            line_counter <= 0;
            data_valid <= 0;
        end else if (line_counter < 32) begin
            data_out <= file_memory[line_counter]; // Envia uma linha
            data_valid <= 1;                       // Sinaliza dado válido
            line_counter <= line_counter + 1;      // Próxima linha
        end else begin
            data_valid <= 0; // Quando termina o arquivo, desativa o dado
        end
    end
endmodule
