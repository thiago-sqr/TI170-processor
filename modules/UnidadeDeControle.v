module control_unit (
    input clock,               // Clock de entrada
    input reset,               // Reset ativo baixo
    input [7:0] IR,            // Registrador de Instrução
    input CCR_Result,          // Resultado do registrador de condições (CCR)
    output reg IR_Load,        // Sinal para carregar o registrador de instrução
    output reg MAR_Load,       // Sinal para carregar o registrador de endereço de memória
    output reg MARR_Load,       // Sinal para carregar o registrador de endereço de memória da resposta
    output reg PC_Load,        // Sinal para carregar o registrador de contador de programa (PC)
    output reg PR_Load,        // Sinal para carregar o registrador de contador de resposta (PR)
    output reg PC_Inc,         // Sinal para incrementar o PC
    output reg A_Load,         // Sinal para carregar o registrador A
    output reg B_Load,         // Sinal para carregar o registrador B
    output reg [3:0] ALU_Sel,  // Seleção da ALU
    output reg CCR_Load,       // Sinal para carregar o registrador de condições
    output reg [1:0] Bus1_Sel, // Seleção para o barramento 1
    output reg [1:0] Bus2_Sel, // Seleção para o barramento 2
    output reg write           // Sinal de escrita em memória ou registradores
);

    // Definição dos estados
    reg [7:0] current_state, next_state;

    // Definindo os estados da máquina de estados
    parameter S_FETCH_0 = 0, S_FETCH_1 = 1, S_FETCH_2 = 2, S_DECODE_3 = 3; // Estados 0, 1 e 2 de busca, e o Estágio de Decodificar a instrução;
    
    parameter S_LDA_IMM_4 = 4, S_LDA_IMM_5 = 5, S_LDA_IMM_6 = 6;           // Carregam um valor determinado para o Registrador A
    parameter S_LDA_DIR_4 = 7, S_LDA_DIR_5 = 8, S_LDA_DIR_6 = 9;           // Carreagam um valor de memória para o Registrador A
    parameter S_STA_DIR_4 = 12, S_STA_DIR_5 = 13;                          // Guardam o valor do Registrador A na memória
    
    parameter S_LDB_IMM_4 = 14, S_LDB_IMM_5 = 15, S_LDB_IMM_6 = 16;        // Carregam um valor determinado para o Registrador B
    parameter S_LDB_DIR_4 = 17, S_LDB_DIR_5 = 18, S_LDB_DIR_6 = 19;        // Carregam um valor da memória para o Registrador B
    parameter S_STB_DIR_4 = 22, S_STB_DIR_5 = 23;                          // Guardam o valor do Registrador B na memória

    parameter ALU_7 = 24, JMP = 25;                                        // Executam operações após coleta de instrução e operando(s)
    
    parameter S_STC_DIR_8 = 32, S_STC_DIR_9 = 33, S_STC_DIR_10 = 34;      // Guardam o valor do Registrador C na memória 

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
            // Estados de coleta da instrução e interpretação (ela é de operação ou salto?)
            S_FETCH_0: next_state <= S_FETCH_1;
            S_FETCH_1: next_state <= S_FETCH_2;
            S_FETCH_2: next_state <= S_DECODE_3;
            S_DECODE_3: begin
                if (IR == 8'h04) next_state <= S_LDB_DIR_4;
                else next_state <= S_LDA_DIR_4;
            end

            // Estados de coleta do primeiro operando e interpretação (é preciso outro operando ou não?)
            S_LDA_DIR_4: next_state <= S_LDA_DIR_5;
            S_LDA_DIR_5: next_state <= S_LDA_DIR_6;
            S_LDA_DIR_6: begin
                if(IR == 8'h03)                     next_state <= ALU_7;
                else if(IR == 8'h01 or IR == 8'h02) next_state <= S_LDB_IMM_4;
                else                                next_state <= S_LDB_DIR_4;
            end

            // Estados em que o Registrador B recebe um valor predefinido (sua única utilização atual
            // é de receber 8'h01, utilizado para incremento ou decremento do operando A)
            S_LDB_IMM_4: next_stage <= S_LDB_IMM_5;
            S_LDB_IMM_5: next_stage <= S_LDB_IMM_6;
            
            // Estados da coleta do segundo operando (ou do tamanho do salto) e interpretação (é um segundo operando ou o tamanho de um salto?)
            S_LDB_DIR_4: next_state <= S_LDB_DIR_5;
            S_LDB_DIR_5: next_state <= S_LDB_DIR_6;
            S_LDB_DIR_6: begin
                if(IR == 8'h04) next_state <= JMP_7;
                else next_state <= ALU_7;
            end

            // Estados que incorporam a saída C à memória de respostas; 
            ALU_7: next_stage <=  S_STC_DIR_8;
            S_STC_DIR_8: next_stage <= S_STC_DIR_9;
            S_STC_DIR_9: next_stage <= S_STC_DIR_10;
            S_STC_DIR_10: next_stage <= FETCH_0;

            JMP_7:
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
        CCR_Load = 0;
        Bus1_Sel = 3'b000;
        Bus2_Sel = 2'b00;
        write = 0;

        case (current_state)
            S_FETCH_0: begin
                MAR_Load = 1;  // Carregar endereço do opcode
                Bus1_Sel = 3'b000; // "000" -> PC
            end
            S_FETCH_1: begin
                PC_Inc = 1;  // Incrementar PC
            end
            S_FETCH_2: begin
                IR_Load = 1;  // Carregar a instrução
                Bus2_Sel = 2'b10; // "10" -> from memory
            end
            
            S_LDA_DIR_4: begin
                MAR_Load = 1;
                Bus1_Sel = 3'b000;
            end
            S_LDA_DIR_5: begin
                PC_Inc = 1;
            end
            S_LDA_DIR_6: begin
                A_Load = 1;  // Carregar 
                write = 1;  // Habilitar escrita
                Bus2_Sel = 2'b10;
            end
            
            S_LDB_DIR_4: begin
                MAR_Load = 1;
                Bus1_Sel = 3'b000;
            end
            S_LDB_DIR_5: begin
                PC_Inc = 1;
                B_Load = 1;  // Carregar 
                write = 1;  // Habilitar escrita
                Bus2_Sel = 2'b10;
            end
            S_LDB_DIR_6: begin
                Bus1_Sel = 3'b010;
                Bus2_Sel = 2'b00;                
            end

            S_LDB_IMM_4: begin
                Bus2_Sel = 2'b01; // Seleciona o valor imediato para o barramento 2
            end
            S_LDB_IMM_5: begin
                B_Load = 1;       // Ativa o carregamento do registrador B
            end
            S_LDB_IMM_6: begin
                next_state = ALU_7; // Retorna ao ciclo de busca
            end

            ALU_7: begin
                case(IR)
                    8'h01: ALU_Sel = 4'h0;  // incremento
                    8'h02: ALU_Sel = 4'h1;  // decremento
                    8'h03: ALU_Sel = 4'h8;  // negação
                 // 8'h04 não é uma instrução da ALU
                    8'h10: ALU_Sel = 4'h0;  // soma
                    8'h20: ALU_Sel = 4'h1;  // subtração
                    8'h30: ALU_Sel = 4'h2;  // multiplicação
                    8'h40: ALU_Sel = 4'h3;  // divisão
                    8'h50: ALU_Sel = 4'h4;  // resto
                    8'h60: ALU_Sel = 4'h6;  // AND
                    8'h70: ALU_Sel = 4'h7;  // OR
                    8'h80: ALU_Sel = 4'hA;  // XOR
                    8'h90: ALU_Sel = 4'hB;  // NAND
                    8'hA0: ALU_Sel = 4'hC;  // NOR
                    8'hB0: ALU_Sel = 4'hD;  // XNOR
                    8'hC0: ALU_Sel = 4'h5;  // comparação
                endcase
            end

            JMP_7: begin
                
    
            end
            // Outros estados conforme a lógica necessária
            default: begin
                // Caso de fallback
            end
        endcase
    end

endmodule
