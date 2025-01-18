`timescale 1ns / 1ps

module testbench;

    // Sinais do testbench
    reg clock;
    reg reset;
    reg [7:0] from_memory; // Sinal de entrada para a memória
    wire [7:0] to_memory;
    wire [7:0] address;
    wire done;

    // Conexões internas do processador
    reg reading_phase, execution_phase; // Fases do processador
    wire [7:0] file_data_out;           // Dados lidos do arquivo
    reg [7:0] ram_address;               // Endereço da RAM
    reg ram_write;                       // Sinal de escrita na RAM
    reg [7:0] ram_data_in;               // Dados a serem escritos na RAM
    wire [7:0] ram_data_out;

    // Registradores e sinais do processador
    wire [7:0] IR, A, B, C, PR, ALU_Result;
    wire [6:0] Flags;
    wire [2:0] Bus1_Sel; 
    wire [1:0] Bus2_Sel, comparacao_resultado;
    wire [3:0] ALU_Sel;
    wire PC_Load, PC_Inc, PR_Inc, A_Load, B_Load, C_Load, IR_Load, MAR_Load, Memory_Load, CCR_Load, write;
    wire [7:0] CCR_Result;

    // Geração do clock
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // Clock de 10ns
    end

    // Inicialização e execução do testbench
    initial begin
        // Inicializa o reset
        reset = 1;
        #10; // Aguarda 10ns
        reset = 0;

        // Aguarda até que o processador termine a execução
        wait(done);
        
        // Aqui você pode adicionar verificações para os resultados
        $display("Processador finalizado. Endereço: %h, Dados: %h", address, to_memory);
        
        // Finaliza a simulação
        $finish;
    end

    // Monitorando o valor de C
    initial begin
        $monitor("Time: %0t | C: %h | A: %h | B: %h | IR: %h | Flags: %b", 
                 $time, C, A, B, IR, Flags);
    end

    // Lógica do processador
    initial begin
        reading_phase = 1;
        execution_phase = 0;
        ram_address = 0;
        ram_write = 0;

        // Instanciação do File Reader
        file_reader FR_inst (
            .clock(clock),
            .reset(reset),
            .read(reading_phase),
            .data_out(file_data_out) // Dados lidos do arquivo
        );

        // Instanciação da Memória RAM
        data_memory RAM_inst (
            .clock(clock),
            .reset(reset),
            .address(ram_address),   // Endereço da RAM
            .data_in(ram_data_in),   // Dados de entrada para a RAM
            .write(ram_write),       // Sinal de escrita na RAM
            .data_out(ram_data_out)  // Dados de saída da RAM
        );

        // Controlador para enviar os dados do File Reader para a RAM
        always @(posedge clock or posedge reset) begin
            if (reset) begin
                ram_address <= 0;
                ram_write <= 0;
                reading_phase <= 1;
            end else if (reading_phase) begin
                if (ram_address < 128) begin
                    ram_data_in <= file_data_out; // Dados do arquivo para a RAM
                    ram_write <= 1;                // Habilita escrita na RAM
                    ram_address <= ram_address + 1; // Avança para a próxima linha
                end else begin
                    ram_write <= 0; // Desabilita escrita quando o arquivo termina
                    reading_phase <= 0;
                    execution_phase <= 1;
                end
            end
        end

        // Instância do caminho de dados
        caminho_dados DatPat_inst (
            .clock(clock), .reset(reset), .execute(execution_phase),
            .Bus1_Sel(Bus1_Sel), .Bus2_Sel(Bus2_Sel),
            .PC_Load(PC_Load), .PC_Inc(PC_Inc), .PR_Inc(PR_Inc),
            .A_Load(A_Load), .B_Load(B_Load), .C_Load(C_Load), .IR_Load(IR_Load), .MAR_Load(MAR_Load),
            .Memory_Load(Memory_Load), .CCR_Load(CCR_Load), .write(write),
            .IR(IR), .A(A), .B(B), .C(C), .PR(PR), .ALU_Result(ALU_Result),
            .Flags(Flags), .CCR_Result(CCR_Result)
        );

        // Lógica de execução do processador
        always @(posedge clock or posedge reset) begin
            if (reset) begin
                // Resetar todos os registradores e sinais
            end else if (execution_phase) begin
                // Executar as instruções do arquivo
                // Aqui você deve implementar a lógica para buscar e executar as instruções
                // Exemplo de verificação de resultado
                if (IR == 8'h01) begin // Supondo que 0x01 seja uma instrução de soma
                    // Verifica se o resultado de C está correto
                    if (C !== (A + B)) begin
                        $display("Erro: C = %h, esperado: %h", C, (A + B));
                    end
                end
                // Adicione mais instruções e verificações conforme necessário
            end
        end
    end
endmodule
