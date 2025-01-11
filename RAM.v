module memoria_dados(
    input wire clock,            // Clock para sincronização
    input wire write,            // Sinal de escrita
    input wire [7:0] endereco,   // Endereço de 8 bits
    input wire [7:0] dado_in,    // Dados de entrada
    output reg [7:0] dado_out    // Dados de saída
);
    reg [7:0] RAM [128:223];     // RAM com 96 posições de 8 bits

    always @(posedge clock) begin
        if (write && (endereco >= 128 && endereco <= 223))
            RAM[endereco] <= dado_in; // Escrever na RAM
        else if (!write && (endereco >= 128 && endereco <= 223))
            dado_out <= RAM[endereco]; // Ler da RAM
    end
endmodule
