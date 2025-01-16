module top_module(
    input wire clock,
    input wire reset,
    output wire done // Indica quando o processo está concluído
);
    // Sinais entre os módulos
    wire [7:0] ram_data_out;
    reg [7:0] ram_address;
    reg [7:0] ram_data_in;
    reg ram_write;
    reg [7:0] ram_memory [0:127]; // Memória de dados da RAM

    // Controle do módulo Answer_Writer
    reg write_enable;
    reg [7:0] data_buffer [0:127];

    // Instância da memória RAM
    data_memory RAM (
        .clock(clock),
        .reset(reset),
        .address(ram_address),
        .data_in(ram_data_in),
        .write(ram_write),
        .data_out(ram_data_out)
    );

    // Instância do módulo Answer_Writer
    answer_writer AnswerWriter (
        .clock(clock),
        .reset(reset),
        .data_in(data_buffer),
        .write_enable(write_enable),
        .answer_size(PR),
        .done(done)
    );

    // Buffer de dados para o módulo Answer_Writer
    always @(posedge clock or posedge reset) begin
      if (write_enable) begin
            integer i;
            for (i = 0; i < PR; i = i + 1) begin
                ram_address <= i;
                #5;
                data_buffer[i] <= ram_data_out;
            end
        end
    end
endmodule
