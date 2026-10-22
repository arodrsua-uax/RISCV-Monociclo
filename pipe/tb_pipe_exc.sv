module tb_pipe_exc;
  logic clk = 0, rst_n;
  integer fallos = 0, i;

  // exc1: instrucciones CSR, fence, wfi y fence.i (sin excepciones)
  // exc2: 12 excepciones; el manejador anota mcause, mtval y mepc
  riscv_pipe #(.INIT_FILE("mem/test_exc1.hex")) dut1 (.clk(clk), .rst_n(rst_n), .ce(1'b1));
  riscv_pipe #(.INIT_FILE("mem/test_exc2.hex")) dut2 (.clk(clk), .rst_n(rst_n), .ce(1'b1));

  always #5 clk = ~clk;

  task chk(input [31:0] valor, input [31:0] esperado, input [8*20-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  // Registro de excepciones de exc2: {mcause, mtval, mepc} desde 0x40
  // (vector plano: el primer valor queda en los bits altos)
  localparam [36*32-1:0] LOG_ESP = {
    32'd11, 32'h00, 32'h1c,     // ecall
    32'd3,  32'h00, 32'h20,     // ebreak
    32'd2,  32'h00, 32'h24,     // 0xffffffff
    32'd2,  32'h00, 32'h28,     // escribir mhartid
    32'd2,  32'h00, 32'h2c,     // CSR inexistente
    32'd2,  32'h00, 32'h30,     // 0x00000000
    32'd4,  32'h02, 32'h38,     // lw desalineado
    32'd6,  32'h01, 32'h3c,     // sw desalineado
    32'd4,  32'h01, 32'h40,     // lh desalineado
    32'd0,  32'h7e, 32'h4c,     // jalr a destino desalineado
    32'd11, 32'h00, 32'h50,     // ecall con un lw y su uso detras
    32'd2,  32'h00, 32'h5c      // sll con funct7 ilegal
  };

  initial begin
    $dumpfile("sim/pipe_exc.vcd");
    $dumpvars(0, tb_pipe_exc);
    rst_n = 0; #12;
    rst_n = 1;

    repeat (300) @(posedge clk);
    #1;

    // ---- exc1 ----
    chk(dut1.rf.regfile_array[6],  32'h55,       "x6 t1");
    chk(dut1.rf.regfile_array[7],  32'h55,       "x7 csrrs");
    chk(dut1.rf.regfile_array[28], 32'h56,       "x28 dependencia");
    chk(dut1.rf.regfile_array[29], 32'h57,       "x29 csrrci");
    chk(dut1.rf.regfile_array[30], 32'h56,       "x30 csrrwi");
    chk(dut1.rf.regfile_array[31], 32'h7,        "x31 mscratch");
    chk(dut1.rf.regfile_array[9],  32'd14,       "x9 forwarding");
    chk(dut1.rf.regfile_array[10], 32'h40000100, "x10 misa");
    chk(dut1.rf.regfile_array[11], 32'h0,        "x11 mhartid");
    chk(dut1.rf.regfile_array[12], 32'h1808,     "x12 mstatus");
    chk(dut1.rf.regfile_array[13], 32'h0,        "x13 mtval viejo");
    chk(dut1.rf.regfile_array[14], 32'h55,       "x14 mtval");
    chk(dut1.rf.regfile_array[15], 32'h54,       "x15 mtvec");
    chk(dut1.rf.regfile_array[16], 32'h1,        "x16 final");
    chk(dut1.rf.regfile_array[17], 32'h5,        "x17 uimm");
    chk(dut1.csrs.mcause_code,     4'd0,         "exc1 sin trap");

    // ---- exc2 ----
    for (i = 0; i < 36; i = i + 1)
      chk(dut2.dm.RAM[16 + i], LOG_ESP[(35-i)*32 +: 32], "registro exc");
    chk(dut2.rf.regfile_array[8],  32'hd0,   "x8 doce traps");
    chk(dut2.rf.regfile_array[3],  32'h0,    "x3 sll ilegal");
    chk(dut2.rf.regfile_array[7],  32'h55,   "x7 lw tras ecall");
    chk(dut2.rf.regfile_array[28], 32'h56,   "x28 uso del lw");
    chk(dut2.rf.regfile_array[12], 32'h0,    "x12 lw no escribe");
    chk(dut2.rf.regfile_array[13], 32'h0,    "x13 lh no escribe");
    chk(dut2.rf.regfile_array[14], 32'h0,    "x14 jalr no escribe");
    chk(dut2.rf.regfile_array[15], 32'h1888, "x15 mstatus final");
    chk(dut2.rf.regfile_array[16], 32'h55,   "x16 sw no escribe");
    chk(dut2.rf.regfile_array[17], 32'h1,    "x17 final");
    chk(dut2.rf.regfile_array[20], 32'h1880, "x20 mstatus trap");

    if (fallos == 0) $display("pipe_exc: todos los tests pasan");
    else             $display("pipe_exc: %0d fallos", fallos);
    $finish;
  end
endmodule
