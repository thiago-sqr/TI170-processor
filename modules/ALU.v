module alu(
    input wire [7:0] A,        // Operando A
    input wire [7:0] B,        // Operando B
    input wire [3:0] operacao, // Seleção de operação
    output reg [7:0] resultado, // Resultado da operação
    output reg [7:0] flags      // Flags (N, Z, C, P, I, D, V, -)
);
    reg carry_out;
    reg parity;

    always @(*) begin
        case (operacao)
            4'b0000: {carry_out, resultado} = A + B;    // Adição
            4'b0001: {carry_out, resultado} = A - B;    // Subtração
            4'b0010: resultado = A & B;                // AND
            4'b0011: resultado = A | B;                // OR
            4'b0100: resultado = A ^ B;                // XOR
            4'b0101: resultado = ~A;                   // NOT
            4'b0110: resultado = A << 1;               // Deslocar para a esquerda
            4'b0111: resultado = A >> 1;               // Deslocar para a direita
            4'b1000: resultado = A * B;                // Multiplicação
            4'b1001: resultado = (B != 0) ? A / B : 8'hFF; // Divisão (proteção contra divisão por zero)
            4'b1010: resultado = (B != 0) ? A % B : 8'hFF; // Resto da divisão
            4'b1011: resultado = (A == B) ? 8'h01 : 8'h00; // Comparação (igualdade)
            4'b1100: resultado = A & ~(1 << B);        // Limpa bit B de A
            4'b1101: resultado = A | (1 << B);        // Seta bit B de A
            default: resultado = 8'h00;                // NOP
        endcase

        // Calculação de Flags
        flags[7] = resultado[7]; // Negativo
        flags[6] = (resultado == 8'h00); // Zero
        flags[5] = carry_out; // Carry
        flags[4] = ^resultado; // Paridade (XOR de todos os bits)
        flags[3] = 0; // Interrupção (Reservado para uso futuro)
        flags[2] = 0; // Direção (Reservado para uso futuro)
        flags[1] = (operacao == 4'b0000 && ((A[7] & B[7] & ~resultado[7]) || (~A[7] & ~B[7] & resultado[7]))); // Overflow
        flags[0] = 0; // Reservado
    end
endmodule
