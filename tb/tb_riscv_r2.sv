module tb_riscv_r2;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv #(.INIT_FILE("mem/test_r2.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/riscv_r2.vcd");
    $dumpvars(0, tb_riscv_r2);

    rst_n = 0; #12;
    rst_n = 1;

    repeat (13) @(posedge clk);   // 13 instrucciones
    #1;

    chk(dut.dp.rf.regfile_array[1],  32'hFFFFFFF0, "r2 x1");
    chk(dut.dp.rf.regfile_array[2],  32'd3,        "r2 x2");
    chk(dut.dp.rf.regfile_array[3],  32'hFFFFFFF3, "r2 xor");
    chk(dut.dp.rf.regfile_array[4],  32'hFFFFFF80, "r2 sll");
    chk(dut.dp.rf.regfile_array[5],  32'h1FFFFFFE, "r2 srl");
    chk(dut.dp.rf.regfile_array[6],  32'hFFFFFFFE, "r2 sra");
    chk(dut.dp.rf.regfile_array[7],  32'd0,        "r2 sltu 0");
    chk(dut.dp.rf.regfile_array[8],  32'd1,        "r2 sltu 1");
    chk(dut.dp.rf.regfile_array[9],  32'd6,        "r2 xori");
    chk(dut.dp.rf.regfile_array[10], 32'd48,       "r2 slli");
    chk(dut.dp.rf.regfile_array[11], 32'h0FFFFFFF, "r2 srli");
    chk(dut.dp.rf.regfile_array[12], 32'hFFFFFFFF, "r2 srai");
    chk(dut.dp.rf.regfile_array[13], 32'd1,        "r2 sltiu");
    chk(dut.PC,                      32'h34,       "r2 PC");

    if (fallos == 0) $display("riscv_r2: todos los tests pasan");
    else             $display("riscv_r2: %0d fallos", fallos);
    $finish;
  end
endmodule