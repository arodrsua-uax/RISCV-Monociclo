module tb_controller;
  logic [31:0] instr;
  logic        Zero, RegWrite, MemWrite, ALUSrc, ASrc;
  logic [1:0]  PCSrc, ResultSrc;
  logic [3:0]  ALUControl;

  controller dut (.instr(instr), .Zero(Zero), .RegWrite(RegWrite), .MemWrite(MemWrite),
                  .ALUSrc(ALUSrc), .ASrc(ASrc), .PCSrc(PCSrc), .ResultSrc(ResultSrc),
                  .ALUControl(ALUControl));

  integer fallos = 0;

  // Comprueba solo PCSrc: el resto de salidas ya lo prueba tb_controldec
  task check(input [31:0] i, input z, input [1:0] esperado, input integer n);
    instr = i; Zero = z; #10;
    if (PCSrc !== esperado) begin
      $display("FALLO %0d: instr=%h Zero=%b PCSrc=%b (esperado %b)", n, instr, Zero, PCSrc, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/controller.vcd");
    $dumpvars(0, tb_controller);

    //    instr          Zero  PCSrc  n
    check(32'h00208463, 1'b1, 2'b01, 1);  // beq tomado (Zero = 1)
    check(32'h00208463, 1'b0, 2'b00, 2);  // beq no tomado (Zero = 0)
    check(32'h008000EF, 1'b0, 2'b01, 3);  // jal salta siempre
    check(32'h008000EF, 1'b1, 2'b01, 4);  // jal salta siempre
    check(32'h402081B3, 1'b1, 2'b00, 5);  // sub con resultado 0: no salta
    check(32'h0030A223, 1'b1, 2'b00, 6);  // sw: no salta
    check(32'h00008067, 1'b0, 2'b10, 7);  // jalr x0, 0(x1): PC = ALUResult
    check(32'h00008067, 1'b1, 2'b10, 8);  // jalr no depende de Zero

    if (fallos == 0) $display("controller: todos los tests pasan");
    $finish;
  end
endmodule
