module somador_completo (A, B, Cin, S, Cout);
    input A, B, Cin;        // Entradas do somador completo
    output S, Cout;         // Soma e carry out

    assign S = A ^ B ^ Cin;         // Soma
    assign Cout = (A & B) | (B & Cin) | (A & Cin);  // Carry
endmodule

module SOMADOR_8BITS (A, B, Cin, Soma, Cout);
    input [7:0] A, B;  // Entradas de 8 bits
    input Cin;          // Carry-in
    output [7:0] Soma;  // Resultado da soma de 8 bits
    output Cout;        // Carry-out (overflow)

    wire [7:0] Carry;  // Carry para cada bit
    wire [7:0] Soma_intermediaria;  // Soma intermediária

    // Instanciando os somadores completos, propagando o carry
    somador_completo U0 (A[0], B[0], Cin, Soma_intermediaria[0], Carry[0]);
    somador_completo U1 (A[1], B[1], Carry[0], Soma_intermediaria[1], Carry[1]);
    somador_completo U2 (A[2], B[2], Carry[1], Soma_intermediaria[2], Carry[2]);
    somador_completo U3 (A[3], B[3], Carry[2], Soma_intermediaria[3], Carry[3]);
    somador_completo U4 (A[4], B[4], Carry[3], Soma_intermediaria[4], Carry[4]);
    somador_completo U5 (A[5], B[5], Carry[4], Soma_intermediaria[5], Carry[5]);
    somador_completo U6 (A[6], B[6], Carry[5], Soma_intermediaria[6], Carry[6]);
    somador_completo U7 (A[7], B[7], Carry[6], Soma_intermediaria[7], Carry[7]);

    // Propagando o carry de cada bit para o próximo
    assign Soma = Soma_intermediaria;
    assign Cout = Carry[7];  // Carry-out (overflow)
endmodule

module ALU (
    input wire [7:0] A, B,             // Operandos de entrada
    input wire [3:0] ALU_Sel,          // Sinal de seleção da operação
    output reg [7:0] C,           // Resultado da operação
    output reg [6:0] Flags,             // Flags: (6) Sinal, (5) Carry, (4) Zero, (3) Paridade, (2) Overflow, (1) Interrupção (0) Direção
    output reg [1:0] comparacao_resultado // Resultado da comparação: 00 - A == B, 01 - A > B, 10 - A < B
    output reg ALU_Cout                 //Cout da Soma
);

    reg [15:0] TempResult;  // Variável auxiliar para operações que geram resultados maiores que 8 bits

    always @(*) begin

        // Inicializando as flags para zero antes de cada operação
        Flags = 7'b0000000;
        comparacao_resultado = 2'b00;
        
        case (ALU_Sel)
            4'h0: begin  // Soma
                SOMADOR_8BITS U1 (A, B, 1'b0, TempResult, ALU_Cout);  // Soma com carry-in 0
                C = TempResult;
                Flags[5] = ALU_Cout;  // Carry Flag
                Flags[6] = C[7];   // Sinal (bit mais significativo)
                Flags[4] = (C == 8'h00) ? 1 : 0;  // Zero Flag
                Flags[3] = (^C);  // Paridade (XOR de todos os bits)
                Flags[2] = (A[7] == B[7]) && (C[7] != A[7]);  // Overflow Flag para soma
                Flags[1] = 0; //Não há chances de ser ativada
                Flags[0] = 0; //Não há chances de ser ativada
            end

            4'h1: begin  // Subtração
                // A - B = A + (~B) + 1
                SOMADOR_8BITS U2 (A, ~B, 1'b1, TempResult, Cout);  // Somar A com o complemento de 2 de B
                C = TempResult;
                Flags[5] = Cout;  // Carry Flag (não aplicável diretamente na subtração, mas pode indicar underflow)
                Flags[6] = C[7];   // Sinal
                Flags[4] = (C == 8'h00) ? 1 : 0;  // Zero Flag
                Flags[3] = (^C);  // Paridade
                Flags[2] = (A[7] != B[7]) && (C[7] != A[7]);  // Overflow Flag para subtração
                Flags[1] = 0; //Não há chances de ser ativada
                Flags[0] = 0; //Não há chances de ser ativada
            end

            4'h2: begin  // Multiplicação
                TempResult = A * B;
                C = TempResult[7:0];
                Flags[6] = 0; //Não há chances de ser ativada
                Flags[5] = 0; //Não há chances de ser ativada
                Flags[4] = 0; //Não há chances de ser ativada
                Flags[3] = C[7];
                Flags[2] = (C == 8'h00) ? 1 : 0;
                Flags[1] = (TempResult > 8'hFF) ? 1 : 0;  // Overflow Flag
                Flags[0] = 0;  // Carry Flag não se aplica
            end

            4'h3: begin  // Divisão
                if (B != 0) begin
                    C = A / B;
                    Flags[6] = 0; //Não há chances de ser ativada
                    Flags[5] = 0; //Não há chances de ser ativada
                    Flags[4] = 0; //Não há chances de ser ativada
                    Flags[3] = C[7];
                    Flags[2] = (C == 8'h00) ? 1 : 0;
                    Flags[1] = 0;  // Overflow não se aplica
                    Flags[0] = 0;  // Carry não se aplica
                end else begin
                    C = 8'hFF;  // Indicador de erro para divisão por zero
                    Flags = 7'h7F;  // Flags indicativas de erro
                end
            end

            4'h4: begin  // Resto da divisão (Módulo)
                if (B != 0) begin
                    C = A % B;
                    Flags[6] = 0; //Não há chances de ser ativada
                    Flags[5] = 0; //Não há chances de ser ativada
                    Flags[4] = 0; //Não há chances de ser ativada
                    Flags[3] = C[7];
                    Flags[2] = (C == 8'h00) ? 1 : 0;
                    Flags[1] = 0;  // Overflow não se aplica
                    Flags[0] = 0;  // Carry não se aplica
                end else begin
                    C = 8'hFF;
                    Flags = 7'h7F;
                end
            end

            4'h5: begin  // Comparação (A == B)
                C = 8'h00;  // Resultado nulo para comparação
                Flags[6] = 0; //Não há chances de ser ativada
                Flags[5] = 0; //Não há chances de ser ativada
                Flags[4] = 0; //Não há chances de ser ativada
                Flags[3] = 0;
                Flags[2] = (A == B) ? 1 : 0; // Zero Flag
                Flags[1] = 0;
                Flags[0] = 0;

                // Atualizando o registrador de comparação
                if (A > B) begin
                    comparacao_resultado = 2'b01;  // A é maior
                end else if (A < B) begin
                    comparacao_resultado = 2'b10;  // A é menor
                end else begin
                    comparacao_resultado = 2'b00;  // A é igual a B
                end
            end
            
            4'h6: C = A & B;  // E (AND)
            4'h7: C = A | B;  // OU (OR)
            4'h8: C = ~A;     // Negação (NOT)
            4'h9: C = ~B;     // Negação (NOT)
            4'hA: C = A ^ B;  // OU-exclusivo (XOR)
            4'hB: C = ~(A & B);  // NAND (NOT AND)
            4'hC: C = ~(A | B);  // NOR (NOT OR)
            4'hD: C = ~(A ^ B);  // XNOR (NOT XOR)

            default: begin
                C = 8'hXX;
                Flags = 7'h7F;
            end
        endcase
    end
endmodule

