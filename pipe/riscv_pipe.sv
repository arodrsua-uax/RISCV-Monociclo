module riscv_pipe #(
  parameter INIT_FILE = "mem/imem.hex"
)(
  input logic clk,
  input logic rst_n
);

  // ================= Etapa IF =================
  logic [31:0] PCTargetE, JalrTargetE;
  logic [1:0]  PCSrcE;
  logic        ZeroE, TakenE;
  logic [31:0] PCF, PCNextF, PCPlus4F, InstrF;

  mux3 pcmux (.d0(PCPlus4F), .d1(PCTargetE), .d2(JalrTargetE),
              .sel3(PCSrcE), .y3(PCNextF));

  flopr pcreg  (.clk(clk), .rst_n(rst_n), .d(PCNextF), .q(PCF));
  adder pcadd4 (.a(PCF), .b(32'd4), .sum(PCPlus4F));
  imem #(.INIT_FILE(INIT_FILE)) im (.addr(PCF), .instr(InstrF));

  // ============== Registro IF/ID ==============
  logic [31:0] InstrD, PCD, PCPlus4D;
  logic [95:0] ifid_d, ifid_q;
  logic FlushD, FlushE;
  assign FlushD = (PCSrcE != 2'b00);
  assign FlushE = (PCSrcE != 2'b00);

  floprc #(96)  ifid (.clk(clk), .rst_n(rst_n), .clr(FlushD), .d(ifid_d), .q(ifid_q));
  
  assign ifid_d = {InstrF, PCF, PCPlus4F};
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
  
  logic [31:0] RD1Dfix, RD2Dfix;
  assign RD1Dfix = (RegWriteW && RdW != 0 && RdW == rs1D) ? ResultW : RD1D;
  assign RD2Dfix = (RegWriteW && RdW != 0 && RdW == rs2D) ? ResultW : RD2D;

  extend ext (.instr(InstrD), .immext(ImmExtD));

  // ============== Registro ID/EX ==============
  logic [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E;
  logic [4:0]  RdE;
  logic [4:0] Rs1E, Rs2E;
  logic        RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE, ASrcE;
  logic [1:0]  ResultSrcE;
  logic [3:0]  ALUControlE;
  logic [2:0]  funct3E;
  logic [190:0] idex_d, idex_q;

  assign idex_d = {RD1Dfix, RD2Dfix, ImmExtD, PCD, PCPlus4D, rdD, rs1D, rs2D,
                   RegWriteD, MemWriteD, BranchD, JumpD, JalrD, ALUSrcD, ASrcD,
                   ResultSrcD, ALUControlD, funct3D};

  floprc #(191) idex (.clk(clk), .rst_n(rst_n), .clr(FlushE), .d(idex_d), .q(idex_q));

  assign {RD1E, RD2E, ImmExtE, PCE, PCPlus4E, RdE, Rs1E, Rs2E,
          RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE, ASrcE,
          ResultSrcE, ALUControlE, funct3E} = idex_q;
  
  
  

  
  

    // ================= Etapa EX =================
  logic [31:0] SrcAE, SrcBE, ALUResultE, WriteDataE;


   logic [1:0]  ForwardAE, ForwardBE;
  logic [31:0] FwdAE, FwdBE;

  forwardunit fu (.Rs1E(Rs1E), .Rs2E(Rs2E), .RdM(RdM), .RdW(RdW),
                  .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
                  .ForwardAE(ForwardAE), .ForwardBE(ForwardBE));

  mux3 fwdamux (.d0(RD1E), .d1(ResultW), .d2(ALUResultM), .sel3(ForwardAE), .y3(FwdAE));
  mux3 fwdbmux (.d0(RD2E), .d1(ResultW), .d2(ALUResultM), .sel3(ForwardBE), .y3(FwdBE));

  mux2 srcamux (.d0(FwdAE), .d1(PCE),     .sel2(ASrcE),   .y2(SrcAE));
  mux2 srcbmux (.d0(FwdBE), .d1(ImmExtE), .sel2(ALUSrcE), .y2(SrcBE));
  assign WriteDataE = FwdBE;

  alu alu0 (.a(SrcAE), .b(SrcBE), .alucontrol(ALUControlE),
            .result(ALUResultE), .zero(ZeroE));

  adder pcaddbranch (.a(PCE), .b(ImmExtE), .sum(PCTargetE));


    always_comb begin
    case (funct3E)
      3'b000:  TakenE =  ZeroE;   // beq
      3'b001:  TakenE = ~ZeroE;   // bne
      3'b100:  TakenE = ~ZeroE;   // blt
      3'b101:  TakenE =  ZeroE;   // bge
      3'b110:  TakenE = ~ZeroE;   // bltu
      3'b111:  TakenE =  ZeroE;   // bgeu
      default: TakenE = 1'b0;
    endcase
  end

  assign PCSrcE       = JalrE ? 2'b10 : {1'b0, JumpE | (BranchE & TakenE)};
  assign JalrTargetE  = {ALUResultE[31:1], 1'b0};

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

  
endmodule