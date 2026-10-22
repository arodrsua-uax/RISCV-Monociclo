module top_pipe_test (
  input  logic       clk100,
  input  logic       btn,
  output logic [3:0] led
);
  logic s1 = 1'b1, s2 = 1'b1;
  always_ff @(posedge clk100) begin s1 <= btn; s2 <= s1; end

  logic [31:0] dbg;
  riscv_pipe #(.INIT_FILE("C:/proyectos/riscv_fpga/src/suma.hex")) cpu
    (.clk(clk100), .rst_n(~s2), .ce(1'b1), .dbg(dbg), .dbg_we());

  assign led = dbg[3:0] ^ dbg[7:4] ^ dbg[11:8] ^ dbg[15:12];
endmodule