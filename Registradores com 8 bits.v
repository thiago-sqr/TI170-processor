module registrador(
    input wire clock,
    input wire reset,
    input wire enable,
    input wire [7:0] dado_in,
    output reg [7:0] dado_out
);
    always @(posedge clock or negedge reset) begin
        if (!reset)
            dado_out <= 8'h00; // Resetar para 0
        else if (enable)
            dado_out <= dado_in; // Atualizar valor
    end
endmodule
