`timescale 1ns / 1ps

module tb_processador8bits();

  // Declaração dos sinais
  reg clock;
  reg reset;
  reg [7:0] from_memory;
  wire [7:0] to_memory;
  wire [7:0] address;
  wire done;

  // Instanciação do módulo
  processador8bits uut (
    .clock(clock),
    .reset(reset),
    .from_memory(from_memory),
    .to_memory(to_memory),
    .address(address),
    .done(done)
  );

  // Geração do clock (50MHz)
  initial begin
    clock = 0;
    forever #5 clock = ~clock; // Período de 20ns
  end

  // Inicialização e simulação
  initial begin
    // Inicializa as entradas
    reset = 0;
    #10;
    reset = 1;
    // Finaliza a simulação
    if(done) $finish;
  end

endmodule
