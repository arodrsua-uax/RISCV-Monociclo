module top_pipe_test (
  input  logic       clk100,
  input  logic       btn,
  output logic [3:0] led
);
  logic s1 = 1'b1, s2 = 1'b1;
  always_ff @(posedge clk100) begin s1 <= btn; s2 <= s1; end

  // Carga serie de la imem desde btn: no es para usarla, sino para que la
  // sintesis no conozca el programa y mida el procesador completo
  logic [38:0] sr = '0;
  always_ff @(posedge clk100) sr <= {sr[37:0], s2};

  logic [31:0] dbg;
  riscv_pipe #(.INIT_FILE("C:/proyectos/riscv_pipe/src/suma.hex")) cpu
    (.clk(clk100), .rst_n(~s2), .ce(1'b1), .dbg(dbg), .dbg_we(),
     .imem_we(sr[38]), .imem_waddr({24'b0, sr[37:32], 2'b00}), .imem_wdata(sr[31:0]));

  assign led = dbg[3:0] ^ dbg[7:4] ^ dbg[11:8] ^ dbg[15:12];
endmodule