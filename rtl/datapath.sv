module datapath (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [1:0]  ResultSrc,
  input  logic [1:0]  PCSrc,       // 00: PC+4, 01: PCTarget, 10: ALUResult (jalr)
  input  logic        ALUSrc,
  input  logic        ASrc,
  input  logic        RegWrite,
  input  logic [3:0]  ALUControl,
  input  logic [31:0] Instr,
  input  logic [31:0] ReadData,
  output logic        Zero,
  output logic [31:0] PC,
  output logic [31:0] ALUResult,
  output logic [31:0] WriteData
);

  // Señales internas
  logic [31:0] PCNext, PCPlus4, PCTarget,ImmExt, RegA, SrcA, SrcB, Result;
  logic [31:0] JalrTarget;

  // ---------- PC ----------
  // jalr: destino = (rs1 + inmediato) con el bit 0 a cero
  assign JalrTarget = {ALUResult[31:1], 1'b0};
   mux3   pcmux       (.d0(PCPlus4), .d1(PCTarget), .d2(JalrTarget), .sel3(PCSrc), .y3(PCNext));
   adder  pcaddbranch (.a(PC), .b(ImmExt), .sum(PCTarget));                     // o PC+4 o PC+inmext
  flopr pcreg (.clk(clk), .rst_n(rst_n), .d(PCNext), .q(PC));
  adder pcadd4 (.a(PC), .b(32'd4), .sum(PCPlus4));

  // ---------- Banco de registros ----------
  regfile rf (
    .clk(clk), .rst_n(rst_n),
    .rs1_addr(Instr[19:15]), .rs2_addr(Instr[24:20]), .rd_addr(Instr[11:7]),
    .rd_data(Result), .rd_write_en(RegWrite),
    .rs1_data(RegA), .rs2_data(WriteData)
  );

  // ---------- Extensión del inmediato ----------
  extend ext (.instr(Instr), .immext(ImmExt));

  // ---------- Mux SrcA (rs1 o PC, este último para auipc) ----------
  mux2 srcamux (.d0(RegA), .d1(PC), .sel2(ASrc), .y2(SrcA));

  // ---------- Mux SrcB ----------
  mux2 srcbmux (.d0(WriteData), .d1(ImmExt), .sel2(ALUSrc), .y2(SrcB));

  // ---------- ALU ----------
  alu alu0 (.a(SrcA), .b(SrcB), .alucontrol(ALUControl),
            .result(ALUResult), .zero(Zero));

  // ---------- Mux de resultado ----------
  // 00: ALUResult, 01: ReadData, 10: PC+4 (jal), 11: inmediato U (lui)
  mux4 resultmux (.d0(ALUResult), .d1(ReadData), .d2(PCPlus4), .d3(ImmExt),
                  .sel4(ResultSrc), .y4(Result));
 

endmodule