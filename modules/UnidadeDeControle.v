module control_unit (
    input clock,          // Clock de entrada
    input reset,          // Reset ativo baixo
    input [7:0] IR,       // Registrador de Instrução
    input CCR_Result,     // Resultado do registrador de condições (CCR)
    output reg IR_Load,   // Sinal para carregar o registrador de instrução
    output reg MAR_Load,  // Sinal para carregar o registrador de endereço de memória
    output reg PC_Load,   // Sinal para carregar o registrador de contador de programa (PC)
    output reg PC_Inc,    // Sinal para incrementar o PC
    output reg A_Load,    // Sinal para carregar o registrador A
    output reg B_Load,    // Sinal para carregar o registrador B
    output reg [2:0] ALU_Sel,  // Seleção da ALU
    output reg CCR_Load,  // Sinal para carregar o registrador de condições
    output reg [1:0] Bus1_Sel, // Seleção para o barramento 1
    output reg [1:0] Bus2_Sel, // Seleção para o barramento 2
    output reg write      // Sinal de escrita em memória ou registradores
);

    // Definição dos estados
    reg [7:0] current_state, next_state;

    // Definindo os estados da máquina de estados
    parameter S_FETCH_0 = 0, S_FETCH_1 = 1, S_FETCH_2 = 2, S_DECODE_3 = 3;
    parameter S_LDA_IMM_4 = 4, S_LDA_IMM_5 = 5, S_LDA_IMM_6 = 6;
    parameter S_LDA_DIR_4 = 7, S_LDA_DIR_5 = 8, S_LDA_DIR_6 = 9;
    parameter S_STA_DIR_4 = 12, S_STA_DIR_5 = 13;
    // Outros estados podem ser definidos conforme a necessidade...

    // Memória de estado (atualiza o estado atual)
    always @ (posedge clock or negedge reset) begin
        if (!reset)
            current_state <= S_FETCH_0;  // Estado inicial após reset
        else
            current_state <= next_state; // Atualiza para o próximo estado
    end

    // Lógica de próximo estado (transições de estados)
    always @ (current_state, IR, CCR_Result) begin
        case (current_state)
            S_FETCH_0: next_state <= S_FETCH_1;
            S_FETCH_1: next_state <= S_FETCH_2;
            S_FETCH_2: next_state <= S_DECODE_3;
            S_DECODE_3: begin
                if (IR == 8'b00000001) next_state <= S_LDA_IMM_4; // LDA_IMM
                else if (IR == 8'b00000010) next_state <= S_LDA_DIR_4; // LDA_DIR
                else next_state <= S_FETCH_0; // Caso não reconheça o código
            end
            // Outros estados de transição
            S_LDA_IMM_4: next_state <= S_LDA_IMM_5;
            S_LDA_IMM_5: next_state <= S_LDA_IMM_6;
            S_LDA_IMM_6: next_state <= S_FETCH_0;
            default: next_state <= S_FETCH_0;
        endcase
    end

    // Lógica de saída (controles de sinal conforme o estado atual)
    always @ (current_state) begin
        // Inicializa todos os sinais em 0
        IR_Load = 0;
        MAR_Load = 0;
        PC_Load = 0;
        PC_Inc = 0;
        A_Load = 0;
        B_Load = 0;
        ALU_Sel = 3'b000;
        CCR_Load = 0;
        Bus1_Sel = 2'b00;
        Bus2_Sel = 2'b00;
        write = 0;

        case (current_state)
            S_FETCH_0: begin
                IR_Load = 0;
                MAR_Load = 1;  // Carregar endereço do opcode
                PC_Load = 0;
                PC_Inc = 0;
                A_Load = 0;
                B_Load = 0;
                ALU_Sel = 3'b000;
                CCR_Load = 0;
                Bus1_Sel = 2'b00; // "00" -> PC
                Bus2_Sel = 2'b01; // "01" -> Bus1
                write = 0;
            end
            S_FETCH_1: begin
                IR_Load = 0;
                MAR_Load = 0;
                PC_Load = 0;
                PC_Inc = 1;  // Incrementar PC
                A_Load = 0;
                B_Load = 0;
                ALU_Sel = 3'b000;
                CCR_Load = 0;
                Bus1_Sel = 2'b00; // "00" -> PC
                Bus2_Sel = 2'b00; // "00" -> ALU
                write = 0;
            end
            S_DECODE_3: begin
                IR_Load = 1;  // Carregar a instrução
                MAR_Load = 0;
                PC_Load = 0;
                PC_Inc = 0;
                A_Load = 0;
                B_Load = 0;
                ALU_Sel = 3'b000;
                CCR_Load = 0;
                Bus1_Sel = 2'b00; // "00" -> PC
                Bus2_Sel = 2'b00; // "00" -> ALU
                write = 0;
            end
            S_LDA_IMM_4: begin
                A_Load = 1;  // Carregar A
                ALU_Sel = 3'b001;  // Seleção da ALU para a operação desejada
                write = 1;  // Habilitar escrita
            end
            S_LDA_IMM_5: begin
                // Configurações adicionais para o LDA_IMM
            end
            // Outros estados conforme a lógica necessária
            default: begin
                // Caso de fallback
            end
        endcase
    end

endmodule
