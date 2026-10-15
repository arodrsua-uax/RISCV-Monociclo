module tb_riscv_jalr;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv #(.INIT_FILE("mem/test_jalr.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/riscv_jalr.vcd");
    $dumpvars(0, tb_riscv_jalr);

    rst_n = 0; #12;
    rst_n = 1;

    repeat (8) @(posedge clk);   // 7 instrucciones utiles + una vuelta del bucle final
    #1;

    chk(dut.dp.rf.regfile_array[6],  32'h1C, "jalr x6");
    chk(dut.dp.rf.regfile_array[1],  32'h08, "jalr x1 (jal)");
    chk(dut.dp.rf.regfile_array[10], 32'd42, "jalr x10");
    chk(dut.dp.rf.regfile_array[5],  32'd43, "jalr x5 (tras ret)");
    chk(dut.dp.rf.regfile_array[7],  32'h10, "jalr x7 (enlace)");
    chk(dut.dp.rf.regfile_array[8],  32'd0,  "jalr x8 (saltado)");
    chk(dut.PC,                      32'h1C, "jalr PC");

    if (fallos == 0) $display("riscv_jalr: todos los tests pasan");
    else             $display("riscv_jalr: %0d fallos", fallos);
    $finish;
  end
endmodule