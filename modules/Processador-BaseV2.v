`timescale 1ns / 1ps

// Memória de Programa (ROM)
module memoria_programa(
    input wire [7:0] endereco,    // Endereço de 8 bits
    output reg [7:0] dado        // Dados de 8 bits
);
    reg [7:0] ROM [0:127];        // ROM com 128 posições de 8 bits

    initial begin
        // Instruções iniciais na ROM
        ROM[0] = 8'h86; // LDA_IMM Exemplo
        ROM[1] = 8'hAA; // Operando
        ROM[2] = 8'h96; // STA_DIR Exemplo
        ROM[3] = 8'hE0; // Endereço de destino
        ROM[4] = 8'h20; // BRA (Branch Always)
        ROM[5] = 8'h00; // Endereço de salto
        // Adicionar mais instruções conforme necessidade
    end

    always @(*) begin
        if (endereco <= 127)
            dado = ROM[endereco];
        else
            dado = 8'h00; // Valor padrão
    end
endmodule

// Memória de Dados (RAM)
module memoria_dados(
    input wire clock,            // Clock para sincronização
    input wire write,            // Sinal de escrita
    input wire [7:0] endereco,   // Endereço de 8 bits
    input wire [7:0] dado_in,    // Dados de entrada
    output reg [7:0] dado_out    // Dados de saída
);
    reg [7:0] RAM [128:223];     // RAM com 96 posições de 8 bits

    always @(posedge clock) begin
        if (write && (endereco >= 128 && endereco <= 223))
            RAM[endereco] <= dado_in; // Escrever na RAM
        else if (!write && (endereco >= 128 && endereco <= 223))
            dado_out <= RAM[endereco]; // Ler da RAM
    end
endmodule

// Registradores com 8 bits
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

// Registrador de Flags
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

// Unidade Lógica e Aritmética (ALU)
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

// Multiplexadores de Barramento
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

// Caminho de Dados da CPU
module caminho_dados(
    input wire clock,
    input wire reset,
    input wire [1:0] bus1_sel,
    input wire [1:0] bus2_sel,
    input wire [3:0] alu_sel,
    input wire [7:0] dado_mem,
    output wire [7:0] endereco_mem,
    output wire [7:0] dado_para_mem
);
    wire [7:0] PC, IR, MAR, R1, R2, R3, bus1, bus2, alu_out;
    wire [7:0] flags;

    // Instâncias de Registradores
    registrador reg_pc(clock, reset, 1'b1, bus2, PC);
    registrador reg_ir(clock, reset, 1'b1, bus2, IR);
    registrador reg_mar(clock, reset, 1'b1, bus2, MAR);
    registrador reg_r1(clock, reset, 1'b1, bus2, R1);
    registrador reg_r2(clock, reset, 1'b1, bus2, R2);
    registrador reg_r3(clock, reset, 1'b1, bus2, R3);

    // Instância da ALU
    alu alu_inst(R1, R2, alu_sel, alu_out, flags);

    // Multiplexadores
    multiplexador mux1(PC, R1, R2, bus1_sel, bus1);
    multiplexador mux2(alu_out, bus1, dado_mem, bus2_sel, bus2);

    // Barramentos
    assign endereco_mem = MAR;
    assign dado_para_mem = bus1;
endmodule

// Processador Completo de 8 bits
module processador_8bits(
    input wire clock,
    input wire reset,
    input wire [7:0] entrada,
    output wire [7:0] saida
);
    // Barramentos e sinais intermediários
    wire [7:0] endereco_mem;
    wire [7:0] dado_para_mem;
    wire [7:0] dado_mem;
    wire [1:0] bus1_sel;
    wire [1:0] bus2_sel;
    wire [2:0] alu_sel;
    wire PC_inc, PC_load, MAR_load, IR_load, A_load, B_load, CCR_load, write;
    wire [3:0] NZVC;           // Flags da ALU

    // Instância da memória de programa (ROM)
    memoria_programa rom(
        .endereco(endereco_mem),
        .dado(dado_mem)
    );

    // Instância da memória de dados (RAM)
    memoria_dados ram(
        .clock(clock),
        .write(write),
        .endereco(endereco_mem),
        .dado_in(dado_para_mem),
        .dado_out(dado_mem)
    );

    // Instância da porta de saída
    porta_saida porta_out(
        .clock(clock),
        .reset(reset),
        .endereco(endereco_mem),
        .dado_in(dado_para_mem),
        .write(write),
        .dado_out(saida)
    );

    // Instância do caminho de dados
    caminho_dados datapath(
        .clock(clock),
        .reset(reset),
        .bus1_sel(bus1_sel),
        .bus2_sel(bus2_sel),
        .alu_sel(alu_sel),
        .dado_mem(dado_mem),
        .endereco_mem(endereco_mem),
        .dado_para_mem(dado_para_mem)
    );

    // Instância da unidade de controle
    unidade_controle control_unit(
        .clock(clock),
        .reset(reset),
        .IR(datapath.IR),       // Instrução atual
        .NZVC(NZVC),            // Flags da ALU
        .bus1_sel(bus1_sel),
        .bus2_sel(bus2_sel),
        .alu_sel(alu_sel),
        .PC_inc(PC_inc),
        .PC_load(PC_load),
        .MAR_load(MAR_load),
        .IR_load(IR_load),
        .A_load(A_load),
        .B_load(B_load),
        .CCR_load(CCR_load),
        .write(write)
    );
endmodule
