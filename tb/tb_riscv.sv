// Ejecuta los programas de mem/ en el procesador completo.
// Ahora los controles los genera el controller: el testbench solo da reloj y reset.
module tb_riscv;
  logic clk = 0, rst_n;

  // Un procesador por programa, todos con el mismo reloj y reset
  riscv #(.INIT_FILE("mem/test_imem.hex")) cpu_imem (.clk(clk), .rst_n(rst_n));
  riscv #(.INIT_FILE("mem/test_r.hex"))    cpu_r    (.clk(clk), .rst_n(rst_n));
  riscv #(.INIT_FILE("mem/test_beq.hex"))  cpu_beq  (.clk(clk), .rst_n(rst_n));
  riscv #(.INIT_FILE("mem/test_jal.hex"))  cpu_jal  (.clk(clk), .rst_n(rst_n));
  riscv #(.INIT_FILE("mem/test_lw.hex"))   cpu_lw   (.clk(clk), .rst_n(rst_n));
  riscv #(.INIT_FILE("mem/test_prog.hex")) cpu_prog (.clk(clk), .rst_n(rst_n));
  riscv #(.INIT_FILE("mem/test_lui.hex"))  cpu_lui  (.clk(clk), .rst_n(rst_n));
  riscv #(.INIT_FILE("mem/test_auipc.hex")) cpu_auipc (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  integer fallos = 0;

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  // Avanza n ciclos de reloj
  task ciclos(input integer n);
    repeat (n) @(posedge clk);
    #1;
  endtask

  initial begin
    $dumpfile("sim/riscv.vcd");
    $dumpvars(0, tb_riscv);

    rst_n = 0; #12;
    rst_n = 1;
    // El primer flanco tras el reset es t=15: cada flanco ejecuta una instrucción.
    // Cada programa se comprueba justo al terminar, antes de que el PC salga
    // de la zona inicializada de la imem.

    ciclos(4);   // test_imem: addi, addi, add, sw x3, 4(x0)
    chk(cpu_imem.dp.rf.regfile_array[1], 32'd5, "imem x1");
    chk(cpu_imem.dp.rf.regfile_array[2], 32'd3, "imem x2");
    chk(cpu_imem.dp.rf.regfile_array[3], 32'd8, "imem x3");
    chk(cpu_imem.dm.RAM[1],              32'd8, "imem mem[4]");
    chk(cpu_imem.PC,                     32'h10, "imem PC");

    ciclos(1);   // test_jal: 5 instrucciones
    chk(cpu_jal.dp.rf.regfile_array[1], 32'h04, "jal x1");
    chk(cpu_jal.dp.rf.regfile_array[2], 32'd0,  "jal x2");   // se saltó el addi
    chk(cpu_jal.dp.rf.regfile_array[3], 32'd1,  "jal x3");
    chk(cpu_jal.dp.rf.regfile_array[4], 32'h10, "jal x4");
    chk(cpu_jal.dp.rf.regfile_array[5], 32'd77, "jal x5");
    chk(cpu_jal.dp.rf.regfile_array[6], 32'h18, "jal x6");
    chk(cpu_jal.PC,                     32'h14, "jal PC");

    ciclos(5);   // test_beq: 10 instrucciones
    chk(cpu_beq.dp.rf.regfile_array[1], 32'd5,  "beq x1");
    chk(cpu_beq.dp.rf.regfile_array[2], 32'd5,  "beq x2");
    chk(cpu_beq.dp.rf.regfile_array[3], 32'd0,  "beq x3");   // se saltó el addi
    chk(cpu_beq.dp.rf.regfile_array[4], 32'd1,  "beq x4");
    chk(cpu_beq.dp.rf.regfile_array[5], 32'd7,  "beq x5");
    chk(cpu_beq.dp.rf.regfile_array[6], 32'd2,  "beq x6");
    chk(cpu_beq.dp.rf.regfile_array[8], 32'd42, "beq x8");
    chk(cpu_beq.PC,                     32'h28, "beq PC");

    ciclos(1);   // test_lw: 11 instrucciones
    chk(cpu_lw.dm.RAM[2],                32'd25,       "lw mem[8]");    // sw x1, 8(x0)
    chk(cpu_lw.dm.RAM[3],                32'hFFFFFFF9, "lw mem[12]");   // sw x2, 12(x0)
    chk(cpu_lw.dp.rf.regfile_array[3],   32'd25,       "lw x3");        // lw x3, 8(x0)
    chk(cpu_lw.dp.rf.regfile_array[4],   32'hFFFFFFF9, "lw x4");        // lw x4, 12(x0)
    chk(cpu_lw.dp.rf.regfile_array[5],   32'd18,       "lw x5");        // add con datos leídos
    chk(cpu_lw.dp.rf.regfile_array[7],   32'hFFFFFFF9, "lw x7");        // lw x7, 4(x6): base + offset
    chk(cpu_lw.dm.RAM[1],                32'd18,       "lw mem[4]");    // sw x5, -4(x6): offset negativo
    chk(cpu_lw.dp.rf.regfile_array[8],   32'd18,       "lw x8");        // lw x8, 4(x0)
    chk(cpu_lw.PC,                       32'h2C,       "lw PC");

    ciclos(3);   // test_r: 14 instrucciones
    chk(cpu_r.dp.rf.regfile_array[1],  32'd5,        "r x1");
    chk(cpu_r.dp.rf.regfile_array[2],  32'd3,        "r x2");
    chk(cpu_r.dp.rf.regfile_array[3],  32'd8,        "r x3");    // add
    chk(cpu_r.dp.rf.regfile_array[4],  32'd2,        "r x4");    // sub
    chk(cpu_r.dp.rf.regfile_array[5],  32'd1,        "r x5");    // and
    chk(cpu_r.dp.rf.regfile_array[6],  32'd7,        "r x6");    // or
    chk(cpu_r.dp.rf.regfile_array[7],  32'd0,        "r x7");    // slt
    chk(cpu_r.dp.rf.regfile_array[8],  32'd1,        "r x8");    // slt
    chk(cpu_r.dp.rf.regfile_array[9],  32'd4,        "r x9");    // addi -1
    chk(cpu_r.dp.rf.regfile_array[10], 32'd4,        "r x10");   // andi
    chk(cpu_r.dp.rf.regfile_array[11], 32'd7,        "r x11");   // ori
    chk(cpu_r.dp.rf.regfile_array[12], 32'd1,        "r x12");   // slti
    chk(cpu_r.dp.rf.regfile_array[13], 32'hFFFFFFFF, "r x13");   // addi x13, x0, -1
    chk(cpu_r.dp.rf.regfile_array[14], 32'd1,        "r x14");   // slt negativo
    chk(cpu_r.dp.rf.regfile_array[0],  32'd0,        "r x0");
    chk(cpu_r.PC,                      32'd56,       "r PC");

    // test_prog: suma 5+4+3+2+1 con un bucle (addi, beq, add, addi, jal) y la guarda con sw.
    // 2 instrucciones iniciales + 5 vueltas x 4 + beq final + sw = 24 ciclos en total;
    // después queda en un bucle infinito (jal x0, 0) en la dirección 0x1C.
    ciclos(10);
    chk(cpu_prog.dp.rf.regfile_array[2], 32'd15, "prog x2");   // suma acumulada
    chk(cpu_prog.dp.rf.regfile_array[3], 32'd0,  "prog x3");   // contador agotado
    chk(cpu_prog.dm.RAM[0],              32'd15, "prog mem[0]");
    chk(cpu_prog.PC,                     32'h1C, "prog PC");
    ciclos(3);                                                 // sigue en el bucle final
    chk(cpu_prog.PC,                     32'h1C, "prog PC fin");

    // test_lui: 6 instrucciones (ya ejecutadas, el PC se queda leyendo la imem sin inicializar,
    // así que se comprueba la memoria y los registros, no el PC)
    chk(cpu_lui.dp.rf.regfile_array[1], 32'h12345678, "lui x1");   // lui + addi
    chk(cpu_lui.dp.rf.regfile_array[2], 32'hFFFFF000, "lui x2");
    chk(cpu_lui.dp.rf.regfile_array[3], 32'h80000000, "lui x3");
    chk(cpu_lui.dp.rf.regfile_array[0], 32'd0,        "lui x0");   // lui x0 se ignora
    chk(cpu_lui.dm.RAM[0],              32'h12345678, "lui mem[0]");

    // test_auipc: rd = PC + (imm << 12), con el PC de cada instrucción
    chk(cpu_auipc.dp.rf.regfile_array[1], 32'h00001004, "auipc x1");   // PC=0x04, imm=0x1000
    chk(cpu_auipc.dp.rf.regfile_array[2], 32'hFFFFF008, "auipc x2");   // PC=0x08, imm=0xFFFFF000
    chk(cpu_auipc.dp.rf.regfile_array[3], 32'h0000000C, "auipc x3");   // PC=0x0C, imm=0
    chk(cpu_auipc.dp.rf.regfile_array[0], 32'd0,        "auipc x0");   // auipc x0 se ignora
    chk(cpu_auipc.dm.RAM[0],              32'h00001004, "auipc mem[0]");

    if (fallos == 0) $display("riscv: todos los tests pasan");
    else             $display("riscv: %0d fallos", fallos);
    $finish;
  end
endmodule
