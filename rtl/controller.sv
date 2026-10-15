module controller (
  input  logic [31:0] instr,
  input  logic        Zero,
  output logic        RegWrite, MemWrite, ALUSrc, ASrc,
  output logic [1:0]  PCSrc,       // 00: PC+4, 01: PC+inmediato (branch, jal), 10: ALUResult (jalr)
  output logic [1:0]  ResultSrc,
  output logic [3:0]  ALUControl
);

  logic Branch, Jump, Jalr;    // señales internas
  logic Taken;                 // se cumple la condición del salto condicional

  controldec dec (
    .instr(instr),
    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .Jump(Jump),
    .Jalr(Jalr),
    .ResultSrc(ResultSrc),
    .ALUSrc(ALUSrc),
    .ASrc(ASrc),
    .ALUControl(ALUControl)
  );

  // Condición de salto según funct3 (la ALU ya ha hecho sub, slt o sltu)
  always_comb begin
    case (instr[14:12])
      3'b000:  Taken =  Zero;   // beq:  rs1 == rs2
      3'b001:  Taken = ~Zero;   // bne:  rs1 != rs2
      3'b100:  Taken = ~Zero;   // blt:  slt = 1
      3'b101:  Taken =  Zero;   // bge:  slt = 0
      3'b110:  Taken = ~Zero;   // bltu: sltu = 1
      3'b111:  Taken =  Zero;   // bgeu: sltu = 0
      default: Taken = 1'b0;
    endcase
  end

  assign PCSrc = Jalr ? 2'b10 : {1'b0, Jump | (Branch & Taken)};
endmodule
