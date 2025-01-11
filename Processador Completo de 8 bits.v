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
