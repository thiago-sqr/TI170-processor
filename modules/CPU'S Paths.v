module caminho_dados (
    input wire clock, reset,
    input wire [1:0] Bus1_Sel, Bus2_Sel,
    input wire PC_Load, PC_Inc, A_Load, B_Load, IR_Load, MAR_Load, CCR_Load,
    input wire [7:0] ALU_Result, from_memory, NZVC,
    output reg [7:0] to_memory, address,
    output reg [7:0] IR, A, B, PC, MAR, CCR_Result
);

    // Barramentos
    reg [7:0] Bus1, Bus2;

    // Multiplexador para Bus1
    always @(*) begin
        case (Bus1_Sel)
            2'b00: Bus1 = PC;
            2'b01: Bus1 = A;
            2'b10: Bus1 = B;
            default: Bus1 = 8'hXX;
        endcase
    end

    // Multiplexador para Bus2
    always @(*) begin
        case (Bus2_Sel)
            2'b00: Bus2 = ALU_Result;
            2'b01: Bus2 = Bus1;
            2'b10: Bus2 = from_memory;
            default: Bus2 = 8'hXX;
        endcase
    end

    // Conexão de memória
    always @(*) begin
        to_memory = Bus1;
        address = MAR;
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
            PC <= MAR + 1;
    end

    // Registradores A e B
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

    // Registrador de Códigos de Condição (CCR)
    always @(posedge clock or negedge reset) begin
        if (!reset)
            CCR_Result <= 8'h00;
        else if (CCR_Load)
            CCR_Result <= NZVC;
    end

endmodule
