module tb_controldec;
  logic [31:0] instr;
  logic        RegWrite, MemWrite, Branch, Jump, Jalr, ALUSrc, ASrc;
  logic [1:0]  ResultSrc;
  logic [3:0]  ALUControl;

  controldec dut (.instr(instr), .RegWrite(RegWrite), .MemWrite(MemWrite),
                  .Branch(Branch), .Jump(Jump), .Jalr(Jalr), .ResultSrc(ResultSrc),
                  .ALUSrc(ALUSrc), .ASrc(ASrc), .ALUControl(ALUControl));

  integer fallos = 0;

  // esperado = {ASrc, RegWrite, MemWrite, Branch, Jump, ResultSrc, ALUSrc, ALUControl}
  task check(input [31:0] i, input [11:0] esperado, input integer n);
    instr = i; #10;
    if ({ASrc, RegWrite, MemWrite, Branch, Jump, ResultSrc, ALUSrc, ALUControl} !== esperado) begin
      $display("FALLO %0d: instr=%h salida=%b (esperado %b)", n, instr,
               {ASrc, RegWrite, MemWrite, Branch, Jump, ResultSrc, ALUSrc, ALUControl}, esperado);
      fallos = fallos + 1;
    end
    if (Jalr !== (i[6:0] == 7'b1100111)) begin   // Jalr solo se activa con jalr
      $display("FALLO %0d: instr=%h Jalr=%b", n, instr, Jalr);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/controldec.vcd");
    $dumpvars(0, tb_controldec);

    //    instr          RW MW Br J  RS  AS ALUC           n
    // Tipo R
    check(32'h002081B3, 12'b0_1_0_0_0_00_0_0000, 1);   // add  x3, x1, x2
    check(32'h402081B3, 12'b0_1_0_0_0_00_0_0001, 2);   // sub  x3, x1, x2
    check(32'h002091B3, 12'b0_1_0_0_0_00_0_1001, 3);   // sll  x3, x1, x2
    check(32'h0020A1B3, 12'b0_1_0_0_0_00_0_0101, 4);   // slt  x3, x1, x2
    check(32'h0020B1B3, 12'b0_1_0_0_0_00_0_1100, 5);   // sltu x3, x1, x2
    check(32'h0020C1B3, 12'b0_1_0_0_0_00_0_1000, 6);   // xor  x3, x1, x2
    check(32'h0020D1B3, 12'b0_1_0_0_0_00_0_1010, 7);   // srl  x3, x1, x2
    check(32'h4020D1B3, 12'b0_1_0_0_0_00_0_1011, 8);   // sra  x3, x1, x2
    check(32'h0020E1B3, 12'b0_1_0_0_0_00_0_0011, 9);   // or   x3, x1, x2
    check(32'h0020F1B3, 12'b0_1_0_0_0_00_0_0010, 10);  // and  x3, x1, x2
    // Tipo I aritmética
    check(32'h00500093, 12'b0_1_0_0_0_00_1_0000, 11);  // addi x1, x0, 5
    check(32'hFFF00093, 12'b0_1_0_0_0_00_1_0000, 12);  // addi x1, x0, -1 (bit 30 = 1, no es sub)
    check(32'h00309093, 12'b0_1_0_0_0_00_1_1001, 13);  // slli x1, x1, 3
    check(32'hFFF0A093, 12'b0_1_0_0_0_00_1_0101, 14);  // slti x1, x1, -1
    check(32'hFFF0B093, 12'b0_1_0_0_0_00_1_1100, 15);  // sltiu x1, x1, -1
    check(32'h0FF0C093, 12'b0_1_0_0_0_00_1_1000, 16);  // xori x1, x1, 255
    check(32'h0030D093, 12'b0_1_0_0_0_00_1_1010, 17);  // srli x1, x1, 3
    check(32'h4030D093, 12'b0_1_0_0_0_00_1_1011, 18);  // srai x1, x1, 3
    check(32'h0FF0E093, 12'b0_1_0_0_0_00_1_0011, 19);  // ori  x1, x1, 255
    check(32'h0FF0F093, 12'b0_1_0_0_0_00_1_0010, 20);  // andi x1, x1, 255
    // Memoria, saltos
    check(32'h0040A183, 12'b0_1_0_0_0_01_1_0000, 21);  // lw   x3, 4(x1)
    check(32'h0030A223, 12'b0_0_1_0_0_00_1_0000, 22);  // sw   x3, 4(x1)
    check(32'h00208463, 12'b0_0_0_1_0_00_0_0001, 23);  // beq  x1, x2, 8
    check(32'h008000EF, 12'b0_1_0_0_1_10_0_0000, 24);  // jal  x1, 8
    check(32'h000000B7, 12'b0_1_0_0_0_11_0_0000, 25);  // lui  x1, 0
    check(32'h00000017, 12'b1_1_0_0_0_00_1_0000, 26);  // auipc x0, 0
    check(32'h000000E7, 12'b0_1_0_0_0_10_1_0000, 27);  // jalr x1, 0(x0)
    check(32'hFFC38067, 12'b0_1_0_0_0_10_1_0000, 28);  // jalr x0, -4(x7)
    // Opcode no soportado: todo a cero
    check(32'h0000007F, 12'b0_0_0_0_0_00_0_0000, 29);

    if (fallos == 0) $display("controldec: todos los tests pasan");
    $finish;
  end
endmodule
