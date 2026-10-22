module top_pipe #(
  parameter DIV             = 32_000_000,   // ciclos de clk100 entre pulsos (>= 2)
  parameter BTN_ACTIVE_HIGH = 1,
  parameter INIT_FILE       = "C:/proyectos/riscv_pipe/src/suma.hex"
)(
  input  logic       clk100,
  input  logic       btn,
  output logic [3:0] led
);
  // Reset sincronizado; arranca en reset
  logic s1 = BTN_ACTIVE_HIGH, s2 = BTN_ACTIVE_HIGH, rst_n;
  always_ff @(posedge clk100) begin s1 <= btn; s2 <= s1; end
  assign rst_n = BTN_ACTIVE_HIGH ? ~s2 : s2;

  // Pulso ce: un ciclo de clk100 cada DIV ciclos, salido de un flip-flop
  logic [$clog2(DIV)-1:0] cnt = '0;
  logic ce = 1'b0;
  always_ff @(posedge clk100)
    if (cnt == DIV-1) begin cnt <= '0;         ce <= 1'b1; end
    else              begin cnt <= cnt + 1'b1; ce <= 1'b0; end

  logic [31:0] dbg;
  logic        dbg_we;
  riscv_pipe #(.INIT_FILE(INIT_FILE)) cpu
    (.clk(clk100), .rst_n(rst_n), .ce(ce), .dbg(dbg), .dbg_we(dbg_we));

  // Los LED solo cambian con escrituras reales en el banco de registros:
  // ni burbujas ni escrituras en x0
  always_ff @(posedge clk100)
    if (!rst_n)      led <= '0;
    else if (dbg_we) led <= dbg[3:0];
endmodule