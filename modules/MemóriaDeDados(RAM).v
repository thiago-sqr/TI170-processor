module data_memory(RAM) (
    input clock,                // Sinal de clock
    input reset,                // Sinal de reset ativo baixo
    input [7:0] address,        // Endereço de memória
    input [7:0] data_in,        // Dados de entrada para a memória
    input write,                // Sinal de escrita
    output reg [7:0] data_out   // Dados de saída da memória
);

    // Declaração da memória de dados (endereço de 128 a 223)
    reg [7:0] RW[128:223];

    // Habilitação interna da memória de dados
    reg EN;
    always @ (address) begin
        if ((address >= 128) && (address <= 223)) 
            EN = 1'b1;
        else 
            EN = 1'b0;
    end

    // Lógica de leitura e escrita na memória de dados
    always @ (posedge clock) begin
        if (write && EN) begin
            RW[address] <= data_in;  // Escreve dados na memória
        end else if (!write && EN) begin
            data_out <= RW[address];  // Lê dados da memória
        end
    end

endmodule
