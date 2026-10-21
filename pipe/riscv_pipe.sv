module riscv_pipe #(
  parameter INIT_FILE = "mem/imem.hex"
)(
  input logic clk,
  input logic rst_n
);

  // ================= Etapa IF =================
  logic [31:0] PCF, PCNextF, PCPlus4F, InstrF;

  assign PCNextF = PCPlus4F;    // por ahora, siempre PC+4

  flopr pcreg  (.clk(clk), .rst_n(rst_n), .d(PCNextF), .q(PCF));
  adder pcadd4 (.a(PCF), .b(32'd4), .sum(PCPlus4F));
  imem #(.INIT_FILE(INIT_FILE)) im (.addr(PCF), .instr(InstrF));

  // ============== Registro IF/ID ==============
  logic [31:0] InstrD, PCD, PCPlus4D;
  logic [95:0] ifid_d, ifid_q;

  assign ifid_d = {InstrF, PCF, PCPlus4F};
  flopr #(96) ifid (.clk(clk), .rst_n(rst_n), .d(ifid_d), .q(ifid_q));
  assign {InstrD, PCD, PCPlus4D} = ifid_q;

   // ================= Etapa ID =================
  logic [4:0]  rs1D, rs2D, rdD;
  logic [2:0]  funct3D;

  assign rdD     = InstrD[11:7];
  assign funct3D = InstrD[14:12];
  assign rs1D    = InstrD[19:15];
  assign rs2D    = InstrD[24:20];

  // Control (sale de controldec)
  logic        RegWriteD, MemWriteD, BranchD, JumpD, JalrD, ALUSrcD, ASrcD;
  logic [1:0]  ResultSrcD;
  logic [3:0]  ALUControlD;

  controldec dec (
    .instr(InstrD),
    .RegWrite(RegWriteD), .MemWrite(MemWriteD), .Branch(BranchD),
    .Jump(JumpD), .Jalr(JalrD), .ResultSrc(ResultSrcD),
    .ALUSrc(ALUSrcD), .ASrc(ASrcD), .ALUControl(ALUControlD)
  );

  // Banco de registros: lectura en ID; la escritura llegará de WB (paso 3)
  logic [31:0] RD1D, RD2D, ImmExtD;
  logic        RegWriteW;
  logic [4:0]  RdW;
  logic [31:0] ResultW;
  logic [6:0] opD;



  assign opD = InstrD[6:0];

  regfile rf (
    .clk(clk), .rst_n(rst_n),
    .rs1_addr(rs1D), .rs2_addr(rs2D), .rd_addr(RdW),
    .rd_data(ResultW), .rd_write_en(RegWriteW),
    .rs1_data(RD1D), .rs2_data(RD2D)
  );

  extend ext (.instr(InstrD), .immext(ImmExtD));

  // ============== Registro ID/EX ==============
  logic [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E;
  logic [4:0]  RdE;
  logic        RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE, ASrcE;
  logic [1:0]  ResultSrcE;
  logic [3:0]  ALUControlE;
  logic [2:0]  funct3E;
  logic [180:0] idex_d, idex_q;

    // ================= Etapa EX =================
  logic [31:0] SrcAE, SrcBE, ALUResultE, WriteDataE, PCTargetE;
  logic        ZeroE;

  mux2 srcamux (.d0(RD1E), .d1(PCE),     .sel2(ASrcE),   .y2(SrcAE));
  mux2 srcbmux (.d0(RD2E), .d1(ImmExtE), .sel2(ALUSrcE), .y2(SrcBE));

  alu alu0 (.a(SrcAE), .b(SrcBE), .alucontrol(ALUControlE),
            .result(ALUResultE), .zero(ZeroE));

  adder pcaddbranch (.a(PCE), .b(ImmExtE), .sum(PCTargetE));
  assign WriteDataE = RD2E;

  // ============== Registro EX/MEM ==============
  logic [31:0] ALUResultM, WriteDataM, PCPlus4M, ImmExtM;
  logic [4:0]  RdM;
  logic        RegWriteM, MemWriteM;
  logic [1:0]  ResultSrcM;
  logic [2:0]  funct3M;
  logic [139:0] exmem_d, exmem_q;

  assign exmem_d = {ALUResultE, WriteDataE, PCPlus4E, ImmExtE, RdE,
                    RegWriteE, MemWriteE, ResultSrcE, funct3E};
  flopr #(140) exmem (.clk(clk), .rst_n(rst_n), .d(exmem_d), .q(exmem_q));
  assign {ALUResultM, WriteDataM, PCPlus4M, ImmExtM, RdM,
          RegWriteM, MemWriteM, ResultSrcM, funct3M} = exmem_q;

  // ================= Etapa MEM =================
  logic [31:0] MemWriteData, MemReadData, ReadDataM;
  logic [3:0]  ByteEn;

  storealign sa (.funct3(funct3M), .addr(ALUResultM[1:0]), .rs2_data(WriteDataM),
                 .write_data(MemWriteData), .byte_en(ByteEn));
  dmem dm (.clk(clk), .mem_write_en(MemWriteM), .byte_en(ByteEn), .addr(ALUResultM),
           .write_data(MemWriteData), .read_data(MemReadData));
  loadext le (.funct3(funct3M), .addr(ALUResultM[1:0]), .mem_data(MemReadData),
              .read_data(ReadDataM));

  // ============== Registro MEM/WB ==============
  logic [31:0] ALUResultW, ReadDataW, PCPlus4W, ImmExtW;
  logic [1:0]  ResultSrcW;
  logic [135:0] memwb_d, memwb_q;

  assign memwb_d = {ALUResultM, ReadDataM, PCPlus4M, ImmExtM, RdM, RegWriteM, ResultSrcM};
  flopr #(136) memwb (.clk(clk), .rst_n(rst_n), .d(memwb_d), .q(memwb_q));
  assign {ALUResultW, ReadDataW, PCPlus4W, ImmExtW, RdW, RegWriteW, ResultSrcW} = memwb_q;

  // ================= Etapa WB =================
  mux4 resultmux (.d0(ALUResultW), .d1(ReadDataW), .d2(PCPlus4W), .d3(ImmExtW),
                  .sel4(ResultSrcW), .y4(ResultW));

  assign idex_d = {RD1D, RD2D, ImmExtD, PCD, PCPlus4D, rdD,
                   RegWriteD, MemWriteD, BranchD, JumpD, JalrD, ALUSrcD, ASrcD,
                   ResultSrcD, ALUControlD, funct3D};

  flopr #(181) idex (.clk(clk), .rst_n(rst_n), .d(idex_d), .q(idex_q));

  assign {RD1E, RD2E, ImmExtE, PCE, PCPlus4E, RdE,
          RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE, ASrcE,
          ResultSrcE, ALUControlE, funct3E} = idex_q;

endmodule