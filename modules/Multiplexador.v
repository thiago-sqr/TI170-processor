module multiplexador(
    input wire [7:0] entrada0,
    input wire [7:0] entrada1,
    input wire [7:0] entrada2,
    input wire [1:0] selecao,
    output reg [7:0] saida
);
    always @(*) begin
        case (selecao)
            2'b00: saida = entrada0;
            2'b01: saida = entrada1;
            2'b10: saida = entrada2;
            default: saida = 8'h00;
        endcase
    end
endmodule
