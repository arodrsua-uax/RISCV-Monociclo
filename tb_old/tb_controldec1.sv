module tb_controldec1;
  logic [31:0] instr;
  logic        Zero, RegWrite, MemWrite, ALUSrc, PCSrc;
  logic [1:0]  ResultSrc;
  logic [3:0]  ALUControl;

  controldec dut (.instr(instr), .Zero(Zero), .RegWrite(RegWrite),
                  .MemWrite(MemWrite), .ALUSrc(ALUSrc), .PCSrc(PCSrc),
                  .ResultSrc(ResultSrc), .ALUControl(ALUControl));

  task check(input [31:0] i, input z, input pcs, input rw, input mw,
             input [3:0] alu, input integer n);
    instr = i; Zero = z; #10;
    if ({PCSrc, RegWrite, MemWrite, ALUControl} !== {pcs, rw, mw, alu})
      $display("FALLO %0d: PCSrc=%b RegWrite=%b MemWrite=%b ALUControl=%b",
               n, PCSrc, RegWrite, MemWrite, ALUControl);
  endtask

  initial begin
    $dumpfile("sim/controldec1.vcd");
    $dumpvars(0, tb_controldec1);

    //    instruccion   Zero PCSrc rw mw  ALUControl  n
    check(32'h002081B3, 0,   0,    1, 0, 4'b0000,   1);  // add, Zero=0
    check(32'h002081B3, 1,   0,    1, 0, 4'b0000,   2);  // add, Zero=1: NO salta
    check(32'h40208233, 0,   0,    1, 0, 4'b0001,   3);  // sub
    check(32'h00208463, 0,   0,    0, 0, 4'b0001,   4);  // beq, no iguales: no salta
    check(32'h00208463, 1,   1,    0, 0, 4'b0001,   5);  // beq, iguales: salta
    check(32'h008000EF, 0,   1,    1, 0, 4'b0000,   6);  // jal, Zero=0: salta
    check(32'h008000EF, 1,   1,    1, 0, 4'b0000,   7);  // jal, Zero=1: salta
    check(32'h00312623, 0,   0,    0, 1, 4'b0000,   8);  // sw
    check(32'h00812183, 0,   0,    1, 0, 4'b0000,   9);  // lw

    $display("Test controller terminado");
    $finish;
  end
endmodule