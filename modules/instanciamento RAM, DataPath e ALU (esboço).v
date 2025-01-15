module top (
    input wire clock, reset,
    input wire [7:0] from_memory,
    output wire [7:0] to_memory, address
);
    wire [7:0] IR, A, B, C, ALU_Result;
    wire [6:0] Flags;
    wire [1:0] Bus1_Sel, Bus2_Sel, comparacao_resultado;
    wire [3:0] ALU_Sel;
    wire PC_Load, PC_Inc, A_Load, B_Load, C_Load, IR_Load, MAR_Load, CCR_Load, write;
    wire [7:0] CCR_Result;

    // Instância do caminho de dados
    caminho_dados u_dpath (
        .clock(clock), .reset(reset),
        .Bus1_Sel(Bus1_Sel), .Bus2_Sel(Bus2_Sel),
        .PC_Load(PC_Load), .PC_Inc(PC_Inc),
        .A_Load(A_Load), .B_Load(B_Load), .C_Load(C_Load),
        .IR_Load(IR_Load), .MAR_Load(MAR_Load), .CCR_Load(CCR_Load),
        .ALU_Result(ALU_Result), .from_memory(from_memory), .NZVC(Flags),
        .to_memory(to_memory), .address(address),
        .IR(IR), .A(A), .B(B), .C(C), .PC(), .MAR(), .CCR_Result(CCR_Result)
    );

    // Instância da unidade de controle
    control_unit u_ctrl (
        .clock(clock), .reset(reset),
        .IR(IR), .CCR_Result(CCR_Result),
        .IR_Load(IR_Load), .MAR_Load(MAR_Load),
        .PC_Load(PC_Load), .PC_Inc(PC_Inc),
        .A_Load(A_Load), .B_Load(B_Load),
        .ALU_Sel(ALU_Sel), .CCR_Load(CCR_Load),
        .Bus1_Sel(Bus1_Sel), .Bus2_Sel(Bus2_Sel),
        .write(write)
    );

    // Instância da ALU
    ALU u_alu (
        .A(A), .B(B),
        .ALU_Sel(ALU_Sel),
        .C(ALU_Result),
        .Flags(Flags),
        .comparacao_resultado(comparacao_resultado),
        .ALU_Cout()
    );
endmodule
