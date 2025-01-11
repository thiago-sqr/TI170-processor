module registrador_flags(
    input wire clock,
    input wire reset,
    input wire [7:0] flags_in,
    output reg [7:0] flags_out
);
    always @(posedge clock or negedge reset) begin
        if (!reset)
            flags_out <= 8'h00; // Resetar flags
        else
            flags_out <= flags_in; // Atualizar flags
    end
endmodule
