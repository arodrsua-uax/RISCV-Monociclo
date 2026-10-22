module imem #(
  parameter INIT_FILE = "mem/imem.hex"
)(
  input  logic [31:0] addr,
  output logic [31:0] instr,
  // Puerto de escritura opcional (sin conectar queda a 0): permite cargar
  // el programa desde fuera y que la sintesis no lo trate como constante
  input  logic        clk   = 1'b0,
  input  logic        we    = 1'b0,
  input  logic [31:0] waddr = '0,
  input  logic [31:0] wdata = '0
);

  logic [31:0] RAM [0:63];   // 64 palabras de 32 bits

  initial $readmemh(INIT_FILE, RAM);

  assign instr = RAM[addr[31:2]];  // addr[1:0] se ignora: direcciones de byte -> palabra

  always_ff @(posedge clk)
    if (we) RAM[waddr[31:2]] <= wdata;
endmodule