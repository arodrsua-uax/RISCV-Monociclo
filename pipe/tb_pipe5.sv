module tb_pipe5;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv_pipe #(.INIT_FILE("mem/test_pipe5.hex")) dut (.clk(clk), .rst_n(rst_n), .ce(1'b1));

  always #5 clk = ~clk;

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/pipe5.vcd");
    $dumpvars(0, tb_pipe5);
    rst_n = 0; #12;
    rst_n = 1;

    repeat (40) @(posedge clk);
    #1;

    chk(dut.rf.regfile_array[1],  32'd5,  "x1");
    chk(dut.rf.regfile_array[2],  32'd8,  "x2");
    chk(dut.rf.regfile_array[3],  32'd13, "x3");
    chk(dut.rf.regfile_array[4],  32'd8,  "x4");
    chk(dut.rf.regfile_array[5],  32'd8,  "x5");
    chk(dut.rf.regfile_array[6],  32'd8,  "x6");
    chk(dut.rf.regfile_array[7],  32'd8,  "x7 lw");
    chk(dut.rf.regfile_array[8],  32'd16, "x8");
    chk(dut.rf.regfile_array[9],  32'd4,  "x9");
    chk(dut.rf.regfile_array[10], 32'd5,  "x10");
    chk(dut.rf.regfile_array[11], 32'd0,  "x11 flush");
    chk(dut.rf.regfile_array[12], 32'd0,  "x12 flush");
    chk(dut.rf.regfile_array[13], 32'd1,  "x13");
    chk(dut.rf.regfile_array[14], 32'd2,  "x14");
    chk(dut.rf.regfile_array[15], 32'd3,  "x15");
    chk(dut.dm.RAM[0],            32'd8,  "RAM[0]");
    chk(dut.dm.RAM[1],            32'd4,  "RAM[1]");

    if (fallos == 0) $display("pipe5: todos los tests pasan");
    else             $display("pipe5: %0d fallos", fallos);
    $finish;
  end
endmodule