module memoria_programa(
    input wire [7:0] endereco,    // Endereço de 8 bits
    output reg [7:0] dado        // Dados de 8 bits
);
    reg [7:0] ROM [0:127];        // ROM com 128 posições de 8 bits

    initial begin
        // Instruções iniciais na ROM
        ROM[0] = 8'h86; // LDA_IMM Exemplo
        ROM[1] = 8'hAA; // Operando
        ROM[2] = 8'h96; // STA_DIR Exemplo
        ROM[3] = 8'hE0; // Endereço de destino
        ROM[4] = 8'h20; // BRA (Branch Always)
        ROM[5] = 8'h00; // Endereço de salto
        // Adicionar mais instruções conforme necessidade
    end

    always @(*) begin
        if (endereco <= 127)
            dado = ROM[endereco];
        else
            dado = 8'h00; // Valor padrão
    end
endmodule
