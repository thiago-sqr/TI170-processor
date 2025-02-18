`timescale 1ns / 1ps

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

module DIVISOR_8BITS (
    input [7:0] Dividend, Divisor,
    output reg [7:0] Quociente,
    output reg [7:0] Resto
);

    integer i; // Variável para contagem
    reg [7:0] temp_dividend; // Variável para armazenar o dividendo durante a iteração
    
    always @(*) begin
        if (Divisor != 0) begin
            Quociente = 0;
            Resto = Dividend;
            temp_dividend = Dividend;
            
            // Subtração sucessiva
            for (i = 0; i < 8; i = i + 1) begin
                if (temp_dividend >= Divisor) begin
                    temp_dividend = temp_dividend - Divisor;
                    Quociente = Quociente + 1;
                end
            end
            Resto = temp_dividend; // O valor restante é o resto
        end else begin
            Quociente = 8'hFF; // Indicador de erro
            Resto = 8'hFF;     // Indicador de erro
        end
    end
endmodule

module MULTIPLICADOR_8BITS (
    input [7:0] A, B,               // Entradas A e B para multiplicação
    output reg [15:0] Produto       // Resultado da multiplicação (16 bits)
);
    integer i;                      // Índice para o loop
    reg [15:0] temp;                // Variável temporária para armazenar o resultado

    always @(*) begin
        Produto = 16'b0;            // Inicializa o Produto como 0
        temp = {8'b0, A};           // Expande A para 16 bits

        for (i = 0; i < 8; i = i + 1) begin
            if (B[i]) begin          // Se o bit i de B for 1
                Produto = Produto + (temp << i); // Adiciona A deslocado
            end
        end
    end
endmodule

module COMPARADOR (
    input [7:0] A, B,
    output reg [1:0] comparacao_resultado
);

    reg [7:0] diferenca; // Variável para armazenar a diferença entre A e B
    reg sinal_diferenca; // Variável para armazenar o sinal da diferença
    
    always @(*) begin
        diferenca = A - B; // Subtrai A por B
        sinal_diferenca = diferenca[7]; // Verifica o bit de sinal da diferença (bit mais significativo)
        
        // Verifica o sinal da diferença para determinar o resultado da comparação
        if (sinal_diferenca == 0 && diferenca != 0) begin
            comparacao_resultado = 2'b01;  // A é maior
        end else if (sinal_diferenca == 1) begin
            comparacao_resultado = 2'b10;  // A é menor
        end else begin
            comparacao_resultado = 2'b00;  // A é igual a B
        end
    end
endmodule

module ALU (
    input wire [7:0] A, B,             // Operandos de entrada
    input wire [3:0] ALU_Sel,          // Sinal de seleção da operação
    output reg [7:0] C,           // Resultado da operação
    output reg [6:0] Flags,             // Flags: (6) Sinal, (5) Carry, (4) Zero, (3) Paridade, (2) Overflow, (1) Interrupção (0) Direção
    output reg [1:0] comparacao_resultado, // Resultado da comparação: 00 - A == B, 01 - A > B, 10 - A < B
    output reg ALU_Cout               // Carry-out da soma
);

    wire [7:0] Soma, Subtracao, Quociente, Resto;
    wire Soma_Cout, Sub_Cout;
    wire [15:0] Produto;                // Variável para armazenar o produto da multiplicação
    wire [1:0] comparacao_resultado_int; // Resultado interno de comparação

    // Instanciação dos módulos
    SOMADOR_8BITS somador_inst (A, B, 1'b0, Soma, Soma_Cout);
    SOMADOR_8BITS subtrator_inst (A, ~B, 1'b1, Subtracao, Sub_Cout);
    MULTIPLICADOR_8BITS multiplicador_inst (A, B, Produto);
    DIVISOR_8BITS divisor_inst (.Dividend(A),.Divisor(B),.Quociente(Quociente),.Resto(Resto));
    COMPARADOR comparador_inst (.A(A),.B(B),.comparacao_resultado(comparacao_resultado_int));
    
    always @(*) begin
        // Inicializando as flags para zero antes de cada operação
        Flags = 7'b0000000;
        comparacao_resultado = 2'b00;
        
        case (ALU_Sel)
            4'h0: begin  // Soma
                C = Soma;
                Flags[5] = Soma_Cout;  // Carry Flag
                Flags[6] = C[7];   // Sinal (bit mais significativo)
                Flags[4] = (C == 8'h00) ? 1 : 0;  // Zero Flag
                Flags[3] = (^C);  // Paridade (XOR de todos os bits)
                Flags[2] = (A[7] == B[7]) && (C[7] != A[7]);  // Overflow Flag para soma
                Flags[1] = 0; //Não há chances de ser ativada
                Flags[0] = 0; //Não há chances de ser ativada
            end

            4'h1: begin  // Subtração
                // A - B = A + (~B) + 1
                C = Subtracao;
                Flags[5] = (A < B) ? 1 : 0;  // Carry Flag (não aplicável diretamente na subtração, mas pode indicar underflow)
                Flags[6] = C[7];   // Sinal
                Flags[4] = (C == 8'h00) ? 1 : 0;  // Zero Flag
                Flags[3] = (^C);  // Paridade
                Flags[2] = (A[7] != B[7]) && (C[7] != A[7]);  // Overflow Flag para subtração
                Flags[1] = 0; //Não há chances de ser ativada
                Flags[0] = 0; //Não há chances de ser ativada
            end

            4'h2: begin  // Multiplicação
                C = Produto[7:0];
                Flags[6] = 0; //Não há chances de ser ativada
                Flags[5] = 0; //Não há chances de ser ativada
                Flags[4] = (C == 8'h00) ? 1 : 0;  // Zero Flag
                Flags[3] = (^C);  // Paridade
                Flags[2] = (Produto[15:8] != 0) ? 1 : 0;  // Overflow Flag (Se os 8 bits mais significativos forem diferentes de 0, houve overflow)
                Flags[1] = 0; //Não há chances de ser ativada
                Flags[0] = 0; //Não há chances de ser ativada
            end

            4'h3: begin  // Divisão
                if (B != 0) begin
                    C = Quociente;
                    Flags[6] = 0; //Não há chances de ser ativada
                    Flags[5] = 0; //Não há chances de ser ativada
                    Flags[4] = (C == 8'h00) ? 1 : 0;  // Zero Flag
                    Flags[3] = (^C);  // Paridade
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
                    C = Resto;
                    Flags[6] = 0; //Não há chances de ser ativada
                    Flags[5] = 0; //Não há chances de ser ativada
                    Flags[4] = 0; //Não há chances de ser ativada
                    Flags[3] = (^C);  // Paridade
                    Flags[2] = (C == 8'h00) ? 1 : 0;
                    Flags[1] = 0; //Não há chances de ser ativada
                    Flags[0] = 0; //Não há chances de ser ativada
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
                Flags[1] = 0; //Não há chances de ser ativada
                Flags[0] = 0; //Não há chances de ser ativada
                // Usando o módulo de comparação baseado em subtração
                comparacao_resultado = comparacao_resultado_int;  // Passa o resultado do comparador
            end
            
            4'h6: begin  // AND
                C = A & B;
                Flags[6] = C[7];                     // Sinal Flag
                Flags[5] = 0;                        // Carry Flag (não aplicável)
                Flags[4] = (C == 8'h00) ? 1 : 0;     // Zero Flag
                Flags[3] = (^C);                    // Paridade Flag
                Flags[2] = 0;                        // Overflow Flag (não aplicável)
                Flags[1] = 0;                        // Interrupção (não aplicável)
                Flags[0] = 0;                        // Direção (não aplicável)
            end
            
            4'h7: begin  // OR
                C = A | B;
                Flags[6] = C[7];                     // Sinal Flag
                Flags[5] = 0;                        // Carry Flag (não aplicável)
                Flags[4] = (C == 8'h00) ? 1 : 0;     // Zero Flag
                Flags[3] = (^C);                    // Paridade Flag
                Flags[2] = 0;                        // Overflow Flag (não aplicável)
                Flags[1] = 0;                        // Interrupção (não aplicável)
                Flags[0] = 0;                        // Direção (não aplicável)
            end
            
            4'h8: begin  // NOT A
                C = ~A;
                Flags[6] = C[7];                     // Sinal Flag
                Flags[5] = 0;                        // Carry Flag (não aplicável)
                Flags[4] = (C == 8'h00) ? 1 : 0;     // Zero Flag
                Flags[3] = (^C);                    // Paridade Flag
                Flags[2] = 0;                        // Overflow Flag (não aplicável)
                Flags[1] = 0;                        // Interrupção (não aplicável)
                Flags[0] = 0;                        // Direção (não aplicável)
            end
            
            4'h9: begin  // NOT B
                C = ~B;
                Flags[6] = C[7];                     // Sinal Flag
                Flags[5] = 0;                        // Carry Flag (não aplicável)
                Flags[4] = (C == 8'h00) ? 1 : 0;     // Zero Flag
                Flags[3] = (^C);                    // Paridade Flag
                Flags[2] = 0;                        // Overflow Flag (não aplicável)
                Flags[1] = 0;                        // Interrupção (não aplicável)
                Flags[0] = 0;                        // Direção (não aplicável)
            end
            
            4'hA: begin  // XOR
                C = A ^ B;
                Flags[6] = C[7];                     // Sinal Flag
                Flags[5] = 0;                        // Carry Flag (não aplicável)
                Flags[4] = (C == 8'h00) ? 1 : 0;     // Zero Flag
                Flags[3] = (^C);                    // Paridade Flag
                Flags[2] = 0;                        // Overflow Flag (não aplicável)
                Flags[1] = 0;                        // Interrupção (não aplicável)
                Flags[0] = 0;                        // Direção (não aplicável)
            end
            
            4'hB: begin  // NAND
                C = ~(A & B);
                Flags[6] = C[7];                     // Sinal Flag
                Flags[5] = 0;                        // Carry Flag (não aplicável)
                Flags[4] = (C == 8'h00) ? 1 : 0;     // Zero Flag
                Flags[3] = (^C);                    // Paridade Flag
                Flags[2] = 0;                        // Overflow Flag (não aplicável)
                Flags[1] = 0;                        // Interrupção (não aplicável)
                Flags[0] = 0;                        // Direção (não aplicável)
            end
            
            4'hC: begin  // NOR
                C = ~(A | B);
                Flags[6] = C[7];                     // Sinal Flag
                Flags[5] = 0;                        // Carry Flag (não aplicável)
                Flags[4] = (C == 8'h00) ? 1 : 0;     // Zero Flag
                Flags[3] = (^C);                    // Paridade Flag
                Flags[2] = 0;                        // Overflow Flag (não aplicável)
                Flags[1] = 0;                        // Interrupção (não aplicável)
                Flags[0] = 0;                        // Direção (não aplicável)
            end
            
            4'hD: begin  // XNOR
                C = ~(A ^ B);
                Flags[6] = C[7];                     // Sinal Flag
                Flags[5] = 0;                        // Carry Flag (não aplicável)
                Flags[4] = (C == 8'h00) ? 1 : 0;     // Zero Flag
                Flags[3] = (^C);                    // Paridade Flag
                Flags[2] = 0;                        // Overflow Flag (não aplicável)
                Flags[1] = 0;                        // Interrupção (não aplicável)
                Flags[0] = 0;                        // Direção (não aplicável)
            end

            default: begin
                C = 8'hXX;
                Flags = 7'h7F;
            end
        endcase
    end
endmodule

