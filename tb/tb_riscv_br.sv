module tb_riscv_br;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv #(.INIT_FILE("mem/test_br.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/riscv_br.vcd");
    $dumpvars(0, tb_riscv_br);

    rst_n = 0; #12;
    rst_n = 1;

    repeat (17) @(posedge clk);   // 17 instrucciones ejecutadas
    #1;

    chk(dut.dp.rf.regfile_array[10], 32'd1, "beq  no salta");
    chk(dut.dp.rf.regfile_array[11], 32'd0, "bne  salta");
    chk(dut.dp.rf.regfile_array[12], 32'd0, "blt  salta");
    chk(dut.dp.rf.regfile_array[13], 32'd1, "bge  no salta");
    chk(dut.dp.rf.regfile_array[14], 32'd1, "bltu no salta");
    chk(dut.dp.rf.regfile_array[15], 32'd0, "bgeu salta");
    chk(dut.dp.rf.regfile_array[16], 32'd0, "bltu salta");
    chk(dut.dp.rf.regfile_array[17], 32'd1, "blt  no salta 2");
    chk(dut.dp.rf.regfile_array[18], 32'd0, "bge  iguales");
    chk(dut.dp.rf.regfile_array[19], 32'd1, "blt  iguales");
    chk(dut.PC,                      32'h58, "br PC");

    if (fallos == 0) $display("riscv_br: todos los tests pasan");
    else             $display("riscv_br: %0d fallos", fallos);
    $finish;
  end
endmodule