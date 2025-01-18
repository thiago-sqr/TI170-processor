module memory_data_out_mux (
    input [7:0] address,               // Endereço de entrada
    input [7:0] rom_data_out,          // Dados da memória de programa
    input [7:0] rw_data_out,           // Dados da memória de dados (RW)
    input [7:0] port_in_00,            // Porta de entrada 00
    input [7:0] port_in_01,            // Porta de entrada 01
    input [7:0] port_in_02,            // Porta de entrada 02
    input [7:0] port_in_03,            // Porta de entrada 03
    input [7:0] port_in_04,            // Porta de entrada 04
    input [7:0] port_in_05,            // Porta de entrada 05
    input [7:0] port_in_06,            // Porta de entrada 06
    input [7:0] port_in_07,            // Porta de entrada 07
    input [7:0] port_in_08,            // Porta de entrada 08
    input [7:0] port_in_09,            // Porta de entrada 09
    input [7:0] port_in_10,            // Porta de entrada 10
    input [7:0] port_in_11,            // Porta de entrada 11
    input [7:0] port_in_12,            // Porta de entrada 12
    input [7:0] port_in_13,            // Porta de entrada 13
    input [7:0] port_in_14,            // Porta de entrada 14
    input [7:0] port_in_15,            // Porta de entrada 15
    output reg [7:0] data_out          // Saída de dados
);

    always @ (address, rom_data_out, rw_data_out,
              port_in_00, port_in_01, port_in_02, port_in_03,
              port_in_04, port_in_05, port_in_06, port_in_07,
              port_in_08, port_in_09, port_in_10, port_in_11,
              port_in_12, port_in_13, port_in_14, port_in_15)
    begin: MUX1
        if ((address >= 8'h00) && (address <= 8'h7F)) begin
            data_out = rom_data_out;  // Programa memória
        end
        else if ((address >= 8'h80) && (address <= 8'hDF)) begin
            data_out = rw_data_out;   // Memória de dados
        end
        else if (address == 8'hF0) data_out = port_in_00;  // Porta de entrada 00
        else if (address == 8'hF1) data_out = port_in_01;  // Porta de entrada 01
        else if (address == 8'hF2) data_out = port_in_02;  // Porta de entrada 02
        else if (address == 8'hF3) data_out = port_in_03;  // Porta de entrada 03
        else if (address == 8'hF4) data_out = port_in_04;  // Porta de entrada 04
        else if (address == 8'hF5) data_out = port_in_05;  // Porta de entrada 05
        else if (address == 8'hF6) data_out = port_in_06;  // Porta de entrada 06
        else if (address == 8'hF7) data_out = port_in_07;  // Porta de entrada 07
        else if (address == 8'hF8) data_out = port_in_08;  // Porta de entrada 08
        else if (address == 8'hF9) data_out = port_in_09;  // Porta de entrada 09
        else if (address == 8'hFA) data_out = port_in_10;  // Porta de entrada 10
        else if (address == 8'hFB) data_out = port_in_11;  // Porta de entrada 11
        else if (address == 8'hFC) data_out = port_in_12;  // Porta de entrada 12
        else if (address == 8'hFD) data_out = port_in_13;  // Porta de entrada 13
        else if (address == 8'hFE) data_out = port_in_14;  // Porta de entrada 14
        else if (address == 8'hFF) data_out = port_in_15;  // Porta de entrada 15
    end
endmodule
