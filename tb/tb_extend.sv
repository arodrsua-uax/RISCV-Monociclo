module tb_extend;
  logic [31:0] instr, immext;
 
  extend dut (instr[31:0], immext);

  task check(input [31:0] i, input [31:0] esperado, input integer n);
    instr = i; #10;
    if (immext !== esperado)
      $display("FALLO %0d: instr=%h immext=%h esperado=%h",
               n, i, immext, esperado);
  endtask

  initial begin
    $dumpfile("sim/extend.vcd");
    $dumpvars(0, tb_extend);

    //     instruccion    esperado      n
    check(32'h00812183,  32'h00000008, 1);  // lw  x3, 8(x2)
    check(32'hFFF10093,  32'hFFFFFFFF, 2);  // addi x1, x2, -1
    check(32'h00312623,  32'h0000000C, 3);  // sw  x3, 12(x2)
    check(32'hFE312C23,  32'hFFFFFFF8, 4);  // sw  x3, -8(x2)
    check(32'h00208463,  32'h00000008, 5);  // beq x1, x2, +8
    check(32'hFE208EE3,  32'hFFFFFFFC, 6);  // beq x1, x2, -4
    check(32'h008000EF,  32'h00000008, 7);  // jal x1, +8
    check(32'hFFDFF0EF,  32'hFFFFFFFC, 8);  // jal x1, -4
  //  check(32'h123452B7,  32'h12345000, 9);   // lui   x5, 0x12345
  //  check(32'hFFFFF0B7,  32'hFFFFF000, 10);  // lui   x1, 0xFFFFF
  //  check(32'h00010317,  32'h00010000, 11);  // auipc x6, 0x10
  //  check(32'h80000197,  32'h80000000, 12);  // auipc x3, 0x80000

    $display("Test extend terminado");
    $finish;
  end
endmodule