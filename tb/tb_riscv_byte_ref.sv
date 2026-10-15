module tb_riscv_byte_ref;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv #(.INIT_FILE("mem/test_byte_ref.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/riscv_byte_ref.vcd");
    $dumpvars(0, tb_riscv_byte_ref);

    rst_n = 0; #12;
    rst_n = 1;

    repeat (17) @(posedge clk);   // 17 instrucciones
    #1;

    chk(dut.dp.rf.regfile_array[1],  32'h8070F001, "x1");
    chk(dut.dp.rf.regfile_array[2],  32'h00000001, "lb  x2");
    chk(dut.dp.rf.regfile_array[3],  32'hFFFFFFF0, "lb  x3");
    chk(dut.dp.rf.regfile_array[4],  32'h000000F0, "lbu x4");
    chk(dut.dp.rf.regfile_array[5],  32'hFFFFF001, "lh  x5");
    chk(dut.dp.rf.regfile_array[6],  32'h00008070, "lhu x6");
    chk(dut.dp.rf.regfile_array[7],  32'hFFFFFF80, "lb  x7");
    chk(dut.dp.rf.regfile_array[8],  32'hFFFF8070, "lh  x8");
    chk(dut.dp.rf.regfile_array[10], 32'h80705501, "lw x10 sb");
    chk(dut.dp.rf.regfile_array[11], 32'h0055F001, "lw x11 sh");
    chk(dut.dm.RAM[0],               32'h8070F001, "RAM[0]");
    chk(dut.dm.RAM[1],               32'h80705501, "RAM[1] sb");
    chk(dut.dm.RAM[2],               32'h0055F001, "RAM[2] sh");
    chk(dut.PC,                      32'h44,       "PC");

    if (fallos == 0) $display("riscv_byte_ref: todos los tests pasan");
    else             $display("riscv_byte_ref: %0d fallos", fallos);
    $finish;
  end
endmodule
