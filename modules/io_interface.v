module io_interface(
    input wire clock,
    input wire reset,
    input wire [7:0] data_in,    // Dados do leitor de arquivo
    input wire data_valid,       // Sinaliza dado disponível
    output reg write_enable,     // Ativa escrita na RAM
    output reg [7:0] data_to_ram,// Dados enviados para a RAM
    output reg [7:0] address     // Endereço da RAM
);

    reg [7:0] current_address; // Endereço atual da RAM

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            current_address <= 8'h00; // Reinicia endereço
            write_enable <= 0;
        end else if (data_valid) begin
            data_to_ram <= data_in;         // Recebe dado do leitor
            address <= current_address;    // Define o endereço da RAM
            write_enable <= 1;             // Habilita escrita na RAM
            current_address <= current_address + 1; // Incrementa endereço
        end else begin
            write_enable <= 0; // Desabilita escrita quando não há dado
        end
    end
endmodule
