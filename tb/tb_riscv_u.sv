module tb_riscv_u;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv #(.INIT_FILE("mem/test_u.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/riscv_u.vcd");
    $dumpvars(0, tb_riscv_u);

    rst_n = 0; #12;
    rst_n = 1;

    repeat (7) @(posedge clk);   // 7 instrucciones
    #1;

    chk(dut.dp.rf.regfile_array[1], 32'h12345678, "u x1");
    chk(dut.dp.rf.regfile_array[2], 32'hFFFFF000, "u x2");
    chk(dut.dp.rf.regfile_array[3], 32'h00001008, "u x3");
    chk(dut.dp.rf.regfile_array[4], 32'hFFFFF00C, "u x4");
    chk(dut.dp.rf.regfile_array[6], 32'h00000014, "u x6");
    chk(dut.dp.rf.regfile_array[0], 32'h0,        "u x0");
    chk(dut.PC,                     32'h1C,       "u PC");

    if (fallos == 0) $display("riscv_u: todos los tests pasan");
    else             $display("riscv_u: %0d fallos", fallos);
    $finish;
  end
endmodule