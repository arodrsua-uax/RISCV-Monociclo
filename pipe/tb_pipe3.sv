module tb_pipe3;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv_pipe #(.INIT_FILE("mem/test_pipe3.hex")) dut (.clk(clk), .rst_n(rst_n), .ce(1'b1));

  always #5 clk = ~clk;

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/pipe3.vcd");
    $dumpvars(0, tb_pipe3);
    rst_n = 0; #12;
    rst_n = 1;

    repeat (40) @(posedge clk);   // 25 instrucciones + 5 de vaciado, con margen
    #1;

    chk(dut.rf.regfile_array[3], 32'd25,       "x3");
    chk(dut.rf.regfile_array[4], 32'hFFFFFFF9, "x4");
    chk(dut.rf.regfile_array[5], 32'd18,       "x5");
    chk(dut.rf.regfile_array[6], 32'd8,        "x6");
    chk(dut.rf.regfile_array[7], 32'hFFFFFFF9, "x7");
    chk(dut.dm.RAM[1],           32'd18,       "RAM[1]");
    chk(dut.dm.RAM[2],           32'd25,       "RAM[2]");
    chk(dut.dm.RAM[3],           32'hFFFFFFF9, "RAM[3]");

    if (fallos == 0) $display("pipe3: todos los tests pasan");
    else             $display("pipe3: %0d fallos", fallos);
    $finish;
  end
endmodule