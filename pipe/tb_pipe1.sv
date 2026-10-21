module tb_pipe1;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv_pipe #(.INIT_FILE("mem/test_imem.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/pipe1.vcd");
    $dumpvars(0, tb_pipe1);

    rst_n = 0; #12;
    chk(dut.PCF,    32'h0, "reset PCF");
    chk(dut.InstrD, 32'h0, "reset InstrD");   // IF/ID vacio: burbuja
    rst_n = 1;

    @(posedge clk); #1;   // t=16: la 1a instruccion entra en ID
    chk(dut.InstrD,   32'h00500093, "InstrD 1");
    chk(dut.PCD,      32'd0,        "PCD 1");
    chk(dut.PCPlus4D, 32'd4,        "PCPlus4D 1");
    chk(dut.PCF,      32'd4,        "PCF 1");       // IF ya va por la siguiente
    chk(dut.InstrF,   32'h00300113, "InstrF 1");

    @(posedge clk); #1;   // t=26
    chk(dut.InstrD,   32'h00300113, "InstrD 2");
    chk(dut.PCD,      32'd4,        "PCD 2");
    chk(dut.PCPlus4D, 32'd8,        "PCPlus4D 2");
    chk(dut.rdD,      32'd2,        "rdD 2");       // addi x2, x0, 3

    @(posedge clk); #1;   // t=36
    chk(dut.InstrD,   32'h002081B3, "InstrD 3");
    chk(dut.rs1D,     32'd1,        "rs1D 3");      // add x3, x1, x2
    chk(dut.rs2D,     32'd2,        "rs2D 3");
    chk(dut.rdD,      32'd3,        "rdD 3");

    @(posedge clk); #1;   // t=46
    chk(dut.InstrD,   32'h00302223, "InstrD 4");
    chk(dut.PCD,      32'd12,       "PCD 4");
    chk(dut.opD,      32'h23,       "opD 4");       // sw

    if (fallos == 0) $display("pipe1: todos los tests pasan");
    else             $display("pipe1: %0d fallos", fallos);
    $finish;
  end
endmodule