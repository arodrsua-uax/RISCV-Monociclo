module dmem (
  input  logic        clk,
  input  logic        mem_write_en,
  input  logic [3:0]  byte_en,      // byte_en[i] = 1: se escribe el byte i de la palabra
  input  logic [31:0] addr,
  input  logic [31:0] write_data,
  output logic [31:0] read_data
);

  logic [31:0] RAM [0:63];   // 64 palabras de 32 bits

  // Lectura combinacional: siempre la palabra entera, loadext elige los bytes
  assign read_data = RAM[addr[31:2]];

  // Escritura síncrona, solo de los bytes habilitados
  always_ff @(posedge clk)
    if (mem_write_en)
      for (int i = 0; i < 4; i++)
        if (byte_en[i]) RAM[addr[31:2]][8*i +: 8] <= write_data[8*i +: 8];
endmodule
