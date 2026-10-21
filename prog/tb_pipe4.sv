module tb_pipe4;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv_pipe #(.INIT_FILE("mem/test_pipe4.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/pipe4.vcd");
    $dumpvars(0, tb_pipe4);
    rst_n = 0; #12;
    rst_n = 1;

    repeat (50) @(posedge clk);
    #1;

    chk(dut.rf.regfile_array[1], 32'd5,   "x1");
    chk(dut.rf.regfile_array[2], 32'd5,   "x2");
    chk(dut.rf.regfile_array[3], 32'd1,   "x3 beq");
    chk(dut.rf.regfile_array[4], 32'd2,   "x4 bne");
    chk(dut.rf.regfile_array[5], 32'h3C,  "x5 jal");
    chk(dut.rf.regfile_array[6], 32'h5C,  "x6");
    chk(dut.rf.regfile_array[7], 32'h58,  "x7 jalr");
    chk(dut.rf.regfile_array[8], 32'd7,   "x8");
    chk(dut.rf.regfile_array[10], 32'd0,  "x10 flush");
    chk(dut.rf.regfile_array[11], 32'd0,  "x11 flush");
    chk(dut.rf.regfile_array[12], 32'd0,  "x12 flush");
    chk(dut.rf.regfile_array[13], 32'd0,  "x13 flush");
    chk(dut.rf.regfile_array[14], 32'd0,  "x14 flush");
    chk(dut.rf.regfile_array[15], 32'd0,  "x15 bad");
    chk(dut.PCF,                 32'h60,  "PC");

    if (fallos == 0) $display("pipe4: todos los tests pasan");
    else             $display("pipe4: %0d fallos", fallos);
    $finish;
  end
endmodule