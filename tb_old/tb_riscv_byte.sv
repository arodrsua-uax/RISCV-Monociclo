// Accesos a memoria de byte y media palabra: lb, lh, lbu, lhu, sb, sh (y lw/sw).
module tb_riscv_byte;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv #(.INIT_FILE("mem/test_byte.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/riscv_byte.vcd");
    $dumpvars(0, tb_riscv_byte);

    rst_n = 0; #12;
    rst_n = 1;

    repeat (23) @(posedge clk);   // 21 instrucciones utiles + dos vueltas del bucle final
    #1;

    // mem[0] = 0x87654321 (sw), después sh x8, 0(x0) -> 0x8765FFFF
    chk(dut.dp.rf.regfile_array[2],  32'h00000021, "lb x2");       // lb  0(x0)
    chk(dut.dp.rf.regfile_array[3],  32'hFFFFFF87, "lb x3");       // lb  3(x0): signo
    chk(dut.dp.rf.regfile_array[4],  32'h00000087, "lbu x4");      // lbu 3(x0): ceros
    chk(dut.dp.rf.regfile_array[5],  32'hFFFF8765, "lh x5");       // lh  2(x0): signo
    chk(dut.dp.rf.regfile_array[6],  32'h00008765, "lhu x6");      // lhu 2(x0): ceros
    chk(dut.dp.rf.regfile_array[7],  32'h00004321, "lh x7");       // lh  0(x0)
    chk(dut.dp.rf.regfile_array[9],  32'h4321FF21, "sb/sh x9");    // sw 0, sb 5, sh 6, sb 4
    chk(dut.dp.rf.regfile_array[10], 32'h000000FF, "lbu x10");     // tras sh x8, 0(x0)
    chk(dut.dp.rf.regfile_array[11], 32'h00000021, "lb x11");      // lb 6(x0)
    chk(dut.dp.rf.regfile_array[13], 32'hFF21FF21, "sb neg x13");  // sb x8, -1(x12)
    chk(dut.dm.RAM[0],               32'h8765FFFF, "mem[0]");
    chk(dut.dm.RAM[1],               32'hFF21FF21, "mem[4]");
    chk(dut.PC,                      32'h54,       "byte PC");

    if (fallos == 0) $display("riscv_byte: todos los tests pasan");
    else             $display("riscv_byte: %0d fallos", fallos);
    $finish;
  end
endmodule
