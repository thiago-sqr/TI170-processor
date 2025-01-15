module caminho_dados (
    input wire clock, reset,
    input wire [2:0] Bus1_Sel,
    input wire [1:0] Bus2_Sel,
    input wire PC_Load, PC_Inc, PR_Inc, A_Load, B_Load, C_Load, IR_Load, MAR_Load, CCR_Load, Memory_Load,
    input wire [7:0] ALU_Result, from_memory, NZVC,
    output reg [7:0] to_memory, address,
    output reg [7:0] IR, A, B, C, PC, MAR, PR, CCR_Result
);

    // Barramentos
    reg [7:0] Bus1, Bus2;

    // Multiplexador para Bus1
    always @(*) begin
        case (Bus1_Sel)
            3'b000: Bus1 = PC;
            3'b001: Bus1 = A;
            3'b010: Bus1 = B;
            3'b011: Bus1 = C;
            3'b100: Bus1 = PR;
            3'b101: Bus1 = IR;
            default: Bus1 = 8'hXX;
        endcase
    end

    // Multiplexador para Bus2
    always @(*) begin
        case (Bus2_Sel)
            2'b00: Bus2 = Bus1;
            2'b01: Bus2 = 8'h01;
            2'b10: Bus2 = from_memory;
            2'b11: Bus2 = ALU_Result;
            default: Bus2 = 8'hXX;
        endcase
    end

    // Conexão de memória
    always @(posedge clock or negedge reset) begin
        if(Memory_Load) begin
            to_memory = Bus1;
            address = MAR;
        end
    end

    // Registrador de Instrução (IR)
    always @(posedge clock or negedge reset) begin
        if (!reset)
            IR <= 8'h00;
        else if (IR_Load)
            IR <= Bus2;
    end

    // Registrador de Endereço de Memória (MAR)
    always @(posedge clock or negedge reset) begin
        if (!reset)
            MAR <= 8'h00;
        else if (MAR_Load)
            MAR <= Bus2;
    end

    // Contador de Programa (PC) com Incremento
    always @(posedge clock or negedge reset) begin
        if (!reset)
            PC <= 8'h00;
        else if (PC_Load)
            PC <= Bus2;
        else if (PC_Inc)
            PC <= PC + 1;
    end

    // Incremento de Contador de Resposta (PR)
    always @(posedge clock or negedge reset) begin
        if (!reset)
            PR <= 8'h00;
        else if (PR_Inc)
            PR <= PR + 1;
    end
    
    // Registradores A, B e C
    always @(posedge clock or negedge reset) begin
        if (!reset)
            A <= 8'h00;
        else if (A_Load)
            A <= Bus2;
    end

    always @(posedge clock or negedge reset) begin
        if (!reset)
            B <= 8'h00;
        else if (B_Load)
            B <= Bus2;
    end

    always @(posedge clock or negedge reset) begin
        if(!reset)
            C <= 8'h00;
        else if (C_Load)
            C <= Bus2;
    end

    // Registrador de Códigos de Condição (CCR)
    always @(posedge clock or negedge reset) begin
        if (!reset)
            CCR_Result <= 8'h00;
        else if (CCR_Load)
            CCR_Result <= NZVC;
    end

endmodule
