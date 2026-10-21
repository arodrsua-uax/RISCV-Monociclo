module tb_pipe6;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv_pipe #(.INIT_FILE("mem/test_pipe6.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/pipe6.vcd");
    $dumpvars(0, tb_pipe6);
    rst_n = 0; #12;
    rst_n = 1;

    repeat (10) begin
      @(posedge clk); #1;
      $display("PCF=%h InstrD=%h lwStall=%b PCSrcE=%b RegWriteW=%b RdW=%0d",
               dut.PCF, dut.InstrD, dut.lwStall, dut.PCSrcE,
               dut.RegWriteW, dut.RdW);
    end

    repeat (40) @(posedge clk);
    #1;

    chk(dut.rf.regfile_array[1],  32'd7,  "x1");
    chk(dut.rf.regfile_array[2],  32'd7,  "x2");
    chk(dut.rf.regfile_array[3],  32'd14, "x3 stall");
    chk(dut.rf.regfile_array[4],  32'd7,  "x4");
    chk(dut.rf.regfile_array[5],  32'd7,  "x5");
    chk(dut.rf.regfile_array[6],  32'd8,  "x6 stall");
    chk(dut.rf.regfile_array[7],  32'd7,  "x7");
    chk(dut.rf.regfile_array[8],  32'd0,  "x8 flush");
    chk(dut.rf.regfile_array[9],  32'd0,  "x9 flush");
    chk(dut.rf.regfile_array[10], 32'd1,  "x10");
    chk(dut.dm.RAM[0],            32'd7,  "RAM[0]");
    chk(dut.dm.RAM[1],            32'd7,  "RAM[1]");

    if (fallos == 0) $display("pipe6: todos los tests pasan");
    else             $display("pipe6: %0d fallos", fallos);
    $finish;
  end
endmodule