module program_memory(ROM) (
    input clock,            // Sinal de clock
    input [7:0] address,    // Endereço de memória
    output reg [7:0] data_out  // Dados de saída
);

    // Definindo os mnemônicos para as instruções
    parameter LDA_IMM = 8'h86;  // Carregar o registrador A com endereçamento imediato
    parameter LDA_DIR = 8'h87;  // Carregar o registrador A com endereçamento direto
    parameter LDB_IMM = 8'h88;  // Carregar o registrador B com endereçamento imediato
    parameter LDB_DIR = 8'h89;  // Carregar o registrador B com endereçamento direto
    parameter STA_DIR = 8'h96;  // Armazenar o registrador A na memória (RAM ou IO)
    parameter STB_DIR = 8'h97;  // Armazenar o registrador B na memória (RAM ou IO)
    parameter ADD_AB = 8'h42;   // A <- A + B
    parameter BRA = 8'h20;      // Salto incondicional (Branch Always)
    parameter BEQ = 8'h23;      // Salto se Z=1 (Branch if Zero flag)

    // Memória ROM (programa)
    reg [7:0] ROM [0:127];

    // Inicialização da memória ROM com um programa simples
    initial begin
        ROM[0]  = LDA_IMM;
        ROM[1]  = 8'hAA;   // Valor imediato a ser carregado em A
        ROM[2]  = STA_DIR;
        ROM[3]  = 8'hE0;   // Endereço de armazenamento (porta de saída 00)
        ROM[4]  = BRA;
        ROM[5]  = 8'h00;   // Endereço de salto (não é usado aqui, mas parte do comando)
    end

    // Sinal de habilitação para garantir que apenas endereços válidos acessem a memória
    reg EN;

    always @ (address) begin
        if ((address >= 0) && (address <= 127)) 
            EN = 1'b1;  // Habilita a leitura se o endereço for válido
        else
            EN = 1'b0;  // Desabilita se o endereço for fora do intervalo
    end

    // Leitura da memória ROM quando o sinal de habilitação (EN) estiver ativo
    always @ (posedge clock) begin
        if (EN)
            data_out <= ROM[address];  // Atribui o dado da ROM ao data_out
    end

endmodule
