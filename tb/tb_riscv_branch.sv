// Prueba los saltos condicionales: beq, bne, blt, bge, bltu, bgeu.
// Cada salto va seguido de un addi que pone a 1 un registro "marca":
// si el salto se toma, el addi se salta y la marca queda a 0.
// x1 = -1 (0xFFFFFFFF), x2 = 1, x3 = 1, para distinguir con/sin signo.
module tb_riscv_branch;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv #(.INIT_FILE("mem/test_branch.hex")) dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/riscv_branch.vcd");
    $dumpvars(0, tb_riscv_branch);

    rst_n = 0; #12;
    rst_n = 1;

    // 21 instrucciones hasta el bucle + 3 vueltas x 3 + addi = 31;
    // después queda en un bucle infinito (jal x0, 0) en 0x80
    repeat (40) @(posedge clk);
    #1;

    chk(dut.dp.rf.regfile_array[10], 32'd0, "bne tomado");     // -1 != 1
    chk(dut.dp.rf.regfile_array[11], 32'd1, "bne no tomado");  //  1 != 1
    chk(dut.dp.rf.regfile_array[12], 32'd0, "blt tomado");     // -1 <  1
    chk(dut.dp.rf.regfile_array[13], 32'd1, "blt no tomado");  //  1 < -1
    chk(dut.dp.rf.regfile_array[14], 32'd0, "bge tomado");     //  1 >= -1
    chk(dut.dp.rf.regfile_array[15], 32'd0, "bge iguales");    //  1 >= 1
    chk(dut.dp.rf.regfile_array[16], 32'd1, "bge no tomado");  // -1 >= 1
    chk(dut.dp.rf.regfile_array[17], 32'd1, "bltu no tomado"); // 0xFFFFFFFF < 1
    chk(dut.dp.rf.regfile_array[18], 32'd0, "bltu tomado");    // 1 < 0xFFFFFFFF
    chk(dut.dp.rf.regfile_array[19], 32'd0, "bgeu tomado");    // 0xFFFFFFFF >= 1
    chk(dut.dp.rf.regfile_array[20], 32'd1, "bgeu no tomado"); // 1 >= 0xFFFFFFFF
    chk(dut.dp.rf.regfile_array[21], 32'd0, "beq tomado");     // 1 == 1
    chk(dut.dp.rf.regfile_array[4],  32'd0, "bucle x4");       // bne hacia atrás
    chk(dut.dp.rf.regfile_array[5],  32'd3, "bucle x5");       // 3 vueltas
    chk(dut.dp.rf.regfile_array[22], 32'd1, "fin x22");
    chk(dut.PC,                      32'h80, "branch PC");

    if (fallos == 0) $display("riscv_branch: todos los tests pasan");
    else             $display("riscv_branch: %0d fallos", fallos);
    $finish;
  end
endmodule
