module imem #(
  parameter INIT_FILE = "mem/imem.hex"
)(
  input  logic [31:0] addr,
  output logic [31:0] instr
);

  logic [31:0] RAM [0:63];   // 64 palabras de 32 bits

  initial $readmemh(INIT_FILE, RAM);

  assign instr = RAM[addr[31:2]];  // addr[1:0] se ignora: direcciones de byte -> palabra
endmodule