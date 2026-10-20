module toy_pipe (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [31:0] x,
  output logic [31:0] result
);

  logic [31:0] n1, r1;   // etapa 1: n1 es el cálculo, r1 lo guardado
  logic [31:0] n2, r2;   // etapa 2
  logic [31:0] n3;       // etapa 3

  // Etapa 1: suma 1
  assign n1 = x + 32'd1;
  flopr reg1 (.clk(clk), .rst_n(rst_n), .d(n1), .q(r1));

  // Etapa 2: multiplica por 2 (desplaza un bit a la izquierda)
  assign n2 = r1 << 1;
  flopr reg2 (.clk(clk), .rst_n(rst_n), .d(n2), .q(r2));

  // Etapa 3: resta 3
  assign n3 = r2 - 32'd3;
  flopr reg3 (.clk(clk), .rst_n(rst_n), .d(n3), .q(result));

endmodule