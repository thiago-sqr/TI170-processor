module reader_to_ram (
    input wire clock,
    input wire reset,
    output wire [7:0] ram_data_out // Dados de saída da RAM (para depuração ou uso futuro)
);

    // Conexões entre os módulos
    wire [7:0] file_data_out; // Dados lidos do arquivo
    reg [7:0] ram_address;    // Endereço da RAM
    reg ram_write;            // Sinal de escrita na RAM
    reg [7:0] ram_data_in;    // Dados a serem escritos na RAM

    // Instanciação do File Reader
    file_reader file_reader_inst (
        .clock(clock),
        .reset(reset),
        .data_out(file_data_out) // Dados lidos do arquivo
    );

    // Instanciação da Memória RAM
    data_memory ram_inst (
        .clock(clock),
        .reset(reset),
        .address(ram_address),   // Endereço da RAM
        .data_in(ram_data_in),   // Dados de entrada para a RAM
        .write(ram_write),       // Sinal de escrita na RAM
        .data_out(ram_data_out)  // Dados de saída da RAM
    );

    // Controlador para enviar os dados do File Reader para a RAM
    reg [7:0] line_counter; // Contador de linhas do arquivo

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            line_counter <= 0;
            ram_address <= 0;
            ram_write <= 0;
        end else begin
            if (line_counter < 128) begin
                ram_data_in <= file_data_out; // Dados do arquivo para a RAM
                ram_address <= line_counter; // Endereço correspondente na RAM
                ram_write <= 1;              // Habilita escrita na RAM
                line_counter <= line_counter + 1; // Avança para a próxima linha
            end else begin
                ram_write <= 0; // Desabilita escrita quando o arquivo termina
            end
        end
    end

endmodule
