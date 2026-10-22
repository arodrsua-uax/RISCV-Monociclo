module riscv_pipe #(
  parameter INIT_FILE = "mem/imem.hex"
)(
  input  logic        clk,
  input  logic        rst_n,
  input  logic        ce,
  output logic [31:0] dbg
);


  // ================= Etapa IF =================
  logic [31:0] PCTargetE, JalrTargetE;
  logic [1:0]  PCSrcE;
  logic        TakenE;
  logic [31:0] PCF, PCNextF, PCPlus4F, InstrF;
  logic StallF;

  mux3 pcmux (.d0(PCPlus4F), .d1(PCTargetE), .d2(JalrTargetE),
              .sel3(PCSrcE), .y3(PCNextF));

  floprec pcreg  (.clk(clk), .rst_n(rst_n), .ce(ce), .en(!StallF), .clr(1'b0),
                .d(PCNextF), .q(PCF));
  adder pcadd4 (.a(PCF), .b(32'd4), .sum(PCPlus4F));
  imem #(.INIT_FILE(INIT_FILE)) im (.addr(PCF), .instr(InstrF));

  // ============== Registro IF/ID ==============
  logic [31:0] InstrD, PCD, PCPlus4D;
  logic [63:0] ifidp_d, ifidp_q;
  logic FlushD, FlushE;

  logic StallD, lwStall;
  logic [1:0]  ResultSrcE;
  logic [4:0]  RdE;
  logic [4:0]  rs1D, rs2D;
  assign lwStall = (ResultSrcE == 2'b01) && (RdE != 0) && (RdE == rs1D || RdE == rs2D);
  assign StallF  = lwStall;
  assign StallD  = lwStall;


  assign FlushD = (PCSrcE != 2'b00);
  assign FlushE = (PCSrcE != 2'b00) || lwStall;

  assign ifidp_d = {PCF, PCPlus4F};

  floprec #(32) ifidi (.clk(clk), .rst_n(rst_n), .ce(ce), .en(!StallD), .clr(FlushD),
                       .d(InstrF), .q(InstrD));
  floprec #(64) ifidp (.clk(clk), .rst_n(rst_n), .ce(ce), .en(!StallD), .clr(1'b0),
                       .d(ifidp_d), .q(ifidp_q));
  assign {PCD, PCPlus4D} = ifidp_q;

  // ================= Etapa ID =================
  logic [4:0]  rdD;
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

  // Banco de registros: lectura en ID; escritura desde WB (solo en pulsos ce).
  // Sin reset para que vaya a LUTRAM
  logic [31:0] RD1D, RD2D, ImmExtD;
  logic        RegWriteW;
  logic [4:0]  RdW;
  logic [31:0] ResultW;
  logic [6:0]  opD;

  assign opD = InstrD[6:0];

  regfile #(.RESET(0)) rf (
    .clk(clk), .rst_n(rst_n),
    .rs1_addr(rs1D), .rs2_addr(rs2D), .rd_addr(RdW),
    .rd_data(ResultW), .rd_write_en(RegWriteW & ce),
    .rs1_data(RD1D), .rs2_data(RD2D)
  );

  logic [31:0] RD1Dfix, RD2Dfix;
  assign RD1Dfix = (RegWriteW && RdW != 0 && RdW == rs1D) ? ResultW : RD1D;
  assign RD2Dfix = (RegWriteW && RdW != 0 && RdW == rs2D) ? ResultW : RD2D;

  extend ext (.instr(InstrD), .immext(ImmExtD));

  // ============== Registro ID/EX ==============
  logic [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E;

  logic        RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE, ASrcE;

  logic [3:0]  ALUControlE;
  logic [2:0]  funct3E;

  // Forwarding calculado en ID: lo que hoy esta en E estara en M y lo que
  // esta en M estara en W cuando esta instruccion llegue a EX (exmem y memwb
  // avanzan en cada ce). La seleccion sale de registro en EX
  logic [1:0]  ForwardAD, ForwardBD;
  logic [4:0]  RdM;
  logic        RegWriteM;
  forwardunit fu (.Rs1E(rs1D), .Rs2E(rs2D), .RdM(RdE), .RdW(RdM),
                  .RegWriteM(RegWriteE), .RegWriteW(RegWriteM),
                  .ForwardAE(ForwardAD), .ForwardBE(ForwardBD));

  logic [177:0] idexd_d, idexd_q;   // datos y control sin vaciar
  logic [6:0]   idexc_d, idexc_q;   // control que se vacia

  assign idexd_d = {RD1Dfix, RD2Dfix, ImmExtD, PCD, PCPlus4D, rdD,
                    ForwardAD, ForwardBD, ALUSrcD, ASrcD, ALUControlD, funct3D};
  assign idexc_d = {RegWriteD, MemWriteD, BranchD, JumpD, JalrD, ResultSrcD};

  floprec #(178) idexd (.clk(clk), .rst_n(rst_n), .ce(ce), .en(1'b1), .clr(1'b0),
                        .d(idexd_d), .q(idexd_q));
  floprc  #(7)   idexc (.clk(clk), .rst_n(rst_n), .ce(ce), .clr(FlushE),
                        .d(idexc_d), .q(idexc_q));

  logic [1:0]  ForwardAE, ForwardBE;
  assign {RD1E, RD2E, ImmExtE, PCE, PCPlus4E, RdE,
          ForwardAE, ForwardBE, ALUSrcE, ASrcE, ALUControlE, funct3E} = idexd_q;
  assign {RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ResultSrcE} = idexc_q;

  // ================= Etapa EX =================
  logic [31:0] SrcAE, SrcBE, ALUResultE, WriteDataE;

  logic [31:0] FwdAE, FwdBE;
  logic [31:0] FwdValM;

  mux3 fwdamux (.d0(RD1E), .d1(ResultW), .d2(FwdValM), .sel3(ForwardAE), .y3(FwdAE));
  mux3 fwdbmux (.d0(RD2E), .d1(ResultW), .d2(FwdValM), .sel3(ForwardBE), .y3(FwdBE));

  mux2 srcamux (.d0(FwdAE), .d1(PCE),     .sel2(ASrcE),   .y2(SrcAE));
  mux2 srcbmux (.d0(FwdBE), .d1(ImmExtE), .sel2(ALUSrcE), .y2(SrcBE));
  assign WriteDataE = FwdBE;

  alu alu0 (.a(SrcAE), .b(SrcBE), .alucontrol(ALUControlE),
            .result(ALUResultE), .zero());

  adder pcaddbranch (.a(PCE), .b(ImmExtE), .sum(PCTargetE));

  // Comparador propio para los saltos: no espera al resultado de la ALU
  // ni a la deteccion de cero (camino critico hacia el PC)
  logic EqE, LtE, LtuE;
  assign EqE  = (FwdAE == FwdBE);
  assign LtE  = ($signed(FwdAE) < $signed(FwdBE));
  assign LtuE = (FwdAE < FwdBE);

  always_comb begin
    case (funct3E)
      3'b000:  TakenE =  EqE;    // beq
      3'b001:  TakenE = ~EqE;    // bne
      3'b100:  TakenE =  LtE;    // blt
      3'b101:  TakenE = ~LtE;    // bge
      3'b110:  TakenE =  LtuE;   // bltu
      3'b111:  TakenE = ~LtuE;   // bgeu
      default: TakenE = 1'b0;
    endcase
  end

  assign PCSrcE       = JalrE ? 2'b10 : {1'b0, JumpE | (BranchE & TakenE)};
  assign JalrTargetE  = {ALUResultE[31:1], 1'b0};

  // ============== Registro EX/MEM ==============
  logic [31:0] ALUResultM, WriteDataM, PCPlus4M;

  logic        MemWriteM;
  logic [1:0]  ResultSrcM;
  logic [2:0]  funct3M;
  logic [139:0] exmem_d, exmem_q;

  // El valor que se reenvia desde M se elige ya en EX: FwdValM sale de
  // registro y ResultSrcM no entra en el camino forwarding -> saltos
  logic [31:0] FwdValE;
  assign FwdValE = (ResultSrcE == 2'b11) ? ImmExtE :
                   (ResultSrcE == 2'b10) ? PCPlus4E : ALUResultE;

  assign exmem_d = {ALUResultE, WriteDataE, PCPlus4E, FwdValE, RdE,
                    RegWriteE, MemWriteE, ResultSrcE, funct3E};
  floprec #(140) exmem (.clk(clk), .rst_n(rst_n), .ce(ce), .en(1'b1), .clr(1'b0),
                        .d(exmem_d), .q(exmem_q));
  assign {ALUResultM, WriteDataM, PCPlus4M, FwdValM, RdM,
          RegWriteM, MemWriteM, ResultSrcM, funct3M} = exmem_q;

  // ================= Etapa MEM =================
  logic [31:0] MemWriteData, MemReadData, ReadDataM;
  logic [3:0]  ByteEn;

  storealign sa (.funct3(funct3M), .addr(ALUResultM[1:0]), .rs2_data(WriteDataM),
                 .write_data(MemWriteData), .byte_en(ByteEn));
  dmem dm (.clk(clk), .mem_write_en(MemWriteM & ce), .byte_en(ByteEn), .addr(ALUResultM),
           .write_data(MemWriteData), .read_data(MemReadData));
  loadext le (.funct3(funct3M), .addr(ALUResultM[1:0]), .mem_data(MemReadData),
              .read_data(ReadDataM));

  // El resultado se elige en MEM: ResultW sale directamente de un registro
  // y no hay mux delante del forwarding desde WB ni del banco de registros
  logic [31:0] ResultM;
  mux2 resultmux (.d0(FwdValM), .d1(ReadDataM), .sel2(ResultSrcM == 2'b01),
                  .y2(ResultM));

  // ============== Registro MEM/WB ==============
  logic [31:0] PCPlus4W;   // solo para las trazas (se elimina en sintesis)
  logic [69:0] memwb_d, memwb_q;

  assign memwb_d = {ResultM, PCPlus4M, RdM, RegWriteM};

  floprec #(70) memwb (.clk(clk), .rst_n(rst_n), .ce(ce), .en(1'b1), .clr(1'b0),
                       .d(memwb_d), .q(memwb_q));

  assign {ResultW, PCPlus4W, RdW, RegWriteW} = memwb_q;

  // ================= Etapa WB =================

  assign dbg = ResultW;

endmodule