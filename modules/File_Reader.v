module file_reader(
    input wire clock,
    input wire reset,
    output reg [7:0] data_out,   // Dados lidos do arquivo
);
    // Memória simulando um arquivo externo
    reg [7:0] file_memory [0:127]; // Arquivo com 128 linhas
    reg [6:0] line_counter;       // Contador de linhas do arquivo

    // Inicializando o arquivo com dados binários
    initial begin
      $readmemb("arquivobinario.bin", file_memory); // Lê o arquivo binário
        line_counter = 0;
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            line_counter <= 0;
        end else if (line_counter < 128) begin
            data_out <= file_memory[line_counter]; // Envia uma linha
            line_counter <= line_counter + 1;      // Próxima linha
        end 
    end
endmodule
