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
