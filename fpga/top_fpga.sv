module top_fpga #(
  parameter DIV_BITS         = 25,          // reloj lento = clk100 / 2^25
  parameter BTN_ACTIVE_HIGH  = 1,           // 1: pulsar da un 1
  parameter INIT_FILE        = "suma.hex"
)(
  input  logic       clk100,
  input  logic       btn,
  output logic [3:0] led
);

  // 1) Reset sincronizado
    logic s1 = BTN_ACTIVE_HIGH, s2 = BTN_ACTIVE_HIGH, rst_n;
  always_ff @(posedge clk100) begin
    s1 <= btn;
    s2 <= s1;
  end
  assign rst_n = BTN_ACTIVE_HIGH ? ~s2 : s2;

  // 2) Reloj lento
  logic [DIV_BITS-1:0] cnt = '0;
  always_ff @(posedge clk100) cnt <= cnt + 1'b1;
  logic clk_slow;
  assign clk_slow = cnt[DIV_BITS-1];

  // 3) Procesador
  logic [31:0] PC, Instr, DataAdr, WriteData;
  logic        MemWrite;

  riscv #(.INIT_FILE(INIT_FILE)) cpu (
    .clk(clk_slow), .rst_n(rst_n),
    .PC(PC), .Instr(Instr), .DataAdr(DataAdr),
    .WriteData(WriteData), .MemWrite(MemWrite)
  );

  // 4) Salida visible
  assign led = PC[5:2];

endmodule