module ALU (
    input wire [7:0] A, B,             // Operandos de entrada
    input wire [3:0] ALU_Sel,          // Sinal de seleção da operação
    output reg [7:0] Result,           // Resultado da operação
    output reg [3:0] NZVC              // Bandeiras de condição: Negativo, Zero, Overflow, Carry
);

    reg [15:0] TempResult;  // Variável auxiliar para operações que geram resultados maiores que 8 bits

    always @(*) begin
        case (ALU_Sel)
            4'h0: begin  // Soma
                {NZVC[0], Result} = A + B;  // Soma e Carry Flag
                NZVC[3] = Result[7];        // Negative Flag
                NZVC[2] = (Result == 8'h00) ? 1 : 0;  // Zero Flag
                NZVC[1] = ((A[7] == B[7]) && (A[7] != Result[7])) ? 1 : 0;  // Overflow Flag
            end

            4'h1: begin  // Subtração
                {NZVC[0], Result} = A - B;
                NZVC[3] = Result[7];
                NZVC[2] = (Result == 8'h00) ? 1 : 0;
                NZVC[1] = ((A[7] != B[7]) && (A[7] != Result[7])) ? 1 : 0;
            end

            4'h2: begin  // Multiplicação
                TempResult = A * B;
                Result = TempResult[7:0];
                NZVC[3] = Result[7];
                NZVC[2] = (Result == 8'h00) ? 1 : 0;
                NZVC[1] = (TempResult > 8'hFF) ? 1 : 0;  // Overflow Flag
                NZVC[0] = 0;  // Carry Flag não se aplica
            end

            4'h3: begin  // Divisão
                if (B != 0) begin
                    Result = A / B;
                    NZVC[3] = Result[7];
                    NZVC[2] = (Result == 8'h00) ? 1 : 0;
                    NZVC[1] = 0;  // Overflow não se aplica
                    NZVC[0] = 0;  // Carry não se aplica
                end else begin
                    Result = 8'hFF;  // Indicador de erro para divisão por zero
                    NZVC = 4'hF;  // Flags indicativas de erro
                end
            end

            4'h4: begin  // Resto da divisão (Módulo)
                if (B != 0) begin
                    Result = A % B;
                    NZVC[3] = Result[7];
                    NZVC[2] = (Result == 8'h00) ? 1 : 0;
                    NZVC[1] = 0;  // Overflow não se aplica
                    NZVC[0] = 0;  // Carry não se aplica
                end else begin
                    Result = 8'hFF;
                    NZVC = 4'hF;
                end
            end

            4'h5: begin  // Comparação (A == B)
                Result = 8'h00;  // Resultado nulo para comparação
                NZVC[3] = 0;
                NZVC[2] = (A == B) ? 1 : 0;
                NZVC[1] = 0;
                NZVC[0] = 0;
            end

            4'h6: Result = A & B;  // E (AND)
            4'h7: Result = A | B;  // OU (OR)
            4'h8: Result = ~A;     // Negacao (NOT)
            4'h9: Result = A ^ B;  // OU-exclusivo (XOR)

            default: begin
                Result = 8'hXX;
                NZVC = 4'hX;
            end
        endcase

        // Atualização de Flags pós-operações lógicas, quando aplicável
        if (ALU_Sel >= 4'h6 && ALU_Sel <= 4'h9) begin
            NZVC[3] = Result[7];                 // Negative Flag
            NZVC[2] = (Result == 8'h00) ? 1 : 0; // Zero Flag
            NZVC[1] = 0;                         // Overflow não se aplica
            NZVC[0] = 0;                         // Carry não se aplica
        end
    end

endmodule
