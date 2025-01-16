`timescale 1ns / 1ps

module tb_integration;

    // Sinais de teste
    reg clock;
    reg reset;
    reg read;
    reg write;
    reg [7:0] address;
    wire [7:0] data_out_reader;
    wire [7:0] data_out_memory;
    
    // Instância do módulo file_reader
    file_reader fr (
        .clock(clock),
        .reset(reset),
        .read(read),
        .data_out(data_out_reader)
    );

    // Instância do módulo data_memory
    data_memory dm (
        .clock(clock),
        .reset(reset),
        .address(address),
        .data_in(data_out_reader),
        .write(write),
        .data_out(data_out_memory)
    );

    // Geração do clock
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // Clock de 10ns
    end

    // Teste
    initial begin
        // Inicialização
        reset = 1;
        read = 0;
        write = 0;
        address = 8'b0;

        // Aguarda alguns ciclos de clock
        #10;
        reset = 0;

        // Lê dados do file_reader e escreve na data_memory
        for (int i = 0; i < 128; i = i + 1) begin
            // Ativa a leitura do file_reader
            read = 1;
            #10; // Aguarda um ciclo de clock
            read = 0;

            // Define o endereço para escrita na data_memory
            address = i;
            write = 1; // Ativa a escrita
            #10; // Aguarda um ciclo de clock
            write = 0; // Desativa a escrita

            // Opcional: Exibe os dados lidos e escritos
            $display("Lido do file_reader: %h, Escrito na data_memory[%d]: %h", data_out_reader, address, data_out_memory);
        end

        // Finaliza a simulação
        $finish;
    end
endmodule
