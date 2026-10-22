module riscv_pipe #(
  parameter INIT_FILE = "mem/imem.hex"
)(
  input  logic        clk,
  input  logic        rst_n,
  input  logic        ce,
  output logic [31:0] dbg,
  output logic        dbg_we,  // dbg es una escritura real en el banco
  // Carga de la memoria de instrucciones (opcional, sin conectar queda a 0)
  input  logic        imem_we    = 1'b0,
  input  logic [31:0] imem_waddr = '0,
  input  logic [31:0] imem_wdata = '0
);


  // ================= Etapa IF =================
  logic [31:0] PCTargetE, JalrTargetE;
  logic [1:0]  PCSrcE;
  logic        TakenE;
  logic [31:0] PCF, PCNextF, PCPlus4F, InstrF;
  logic StallF;

  // Excepcion o mret en MEM: el PC va a mtvec o a mepc. RedirM y RedirTargetM
  // salen de registros; la redireccion solo anade una entrada al mux del PC
  logic        RedirM;
  logic [31:0] RedirTargetM;
  logic [1:0]  PCSelF;
  assign PCSelF = RedirM ? 2'b11 : PCSrcE;

  mux4 pcmux (.d0(PCPlus4F), .d1(PCTargetE), .d2(JalrTargetE), .d3(RedirTargetM),
              .sel4(PCSelF), .y4(PCNextF));

  floprec pcreg  (.clk(clk), .rst_n(rst_n), .ce(ce), .en(!StallF), .clr(1'b0),
                .d(PCNextF), .q(PCF));
  adder pcadd4 (.a(PCF), .b(32'd4), .sum(PCPlus4F));
  imem #(.INIT_FILE(INIT_FILE)) im (.addr(PCF), .instr(InstrF),
                                    .clk(clk), .we(imem_we), .waddr(imem_waddr),
                                    .wdata(imem_wdata));

  // ============== Registro IF/ID ==============
  logic [31:0] InstrD, PCD, PCPlus4D;
  logic [63:0] ifidp_d, ifidp_q;
  logic FlushD, FlushE;
  logic ValidD;

  // Las cargas y las instrucciones CSR dan el resultado en MEM: si la
  // siguiente lo usa, espera un ciclo
  logic StallD, lwStall;
  logic [1:0]  ResultSrcE;
  logic        CsrE;
  logic [4:0]  RdE;
  logic [4:0]  rs1D, rs2D;
  assign lwStall = ValidD && ((ResultSrcE == 2'b01) || CsrE) && (RdE != 0) &&
                   (RdE == rs1D || RdE == rs2D);
  assign StallF  = lwStall && !RedirM;   // la redireccion no puede esperar
  assign StallD  = lwStall;


  assign FlushD = (PCSrcE != 2'b00);
  assign FlushE = (PCSrcE != 2'b00) || lwStall;

  assign ifidp_d = {PCF, PCPlus4F};

  // El vaciado de IF/ID no toca InstrD: solo baja ValidD y en ID se anula
  // el control. Asi PCSrcE llega a un flip-flop y no al CE de 32
  floprec #(32) ifidi (.clk(clk), .rst_n(rst_n), .ce(ce), .en(!StallD), .clr(1'b0),
                       .d(InstrF), .q(InstrD));
  floprec #(1)  ifidv (.clk(clk), .rst_n(rst_n), .ce(ce), .en(!StallD), .clr(FlushD),
                       .d(1'b1), .q(ValidD));
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

  assign opD = InstrD[6:0];   // solo para los testbench

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

  // Excepciones detectadas en ID y acceso a CSR
  logic IllegalD, EcallD, EbreakD, MretD, CsrD, CsrWriteD, CsrImmD, ExcD;
  logic [3:0] CauseD;
  sysdec sd (.instr(InstrD), .Illegal(IllegalD), .Ecall(EcallD), .Ebreak(EbreakD),
             .Mret(MretD), .Csr(CsrD), .CsrWrite(CsrWriteD));
  assign ExcD    = IllegalD || EcallD || EbreakD;
  assign CauseD  = IllegalD ? 4'd2 : EbreakD ? 4'd3 : 4'd11;
  assign CsrImmD = CsrD && funct3D[2];

  // Una instruccion CSR escribe rd con el CSR leido en MEM. En EX lleva la
  // direccion del CSR como inmediato (y sale en FwdValM) y el operando en
  // RD1: rs1 o, en las variantes con inmediato, uimm (sin forwarding)
  logic [31:0] RD1Dop, ImmExtDx;
  logic        RegWriteDx;
  logic [1:0]  ResultSrcDx;
  assign RD1Dop      = CsrImmD ? {27'b0, rs1D} : RD1Dfix;
  assign ImmExtDx    = CsrD ? {20'b0, InstrD[31:20]} : ImmExtD;
  assign RegWriteDx  = RegWriteD || CsrD;
  assign ResultSrcDx = CsrD ? 2'b11 : ResultSrcD;

  // ============== Registro ID/EX ==============
  logic [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E;

  logic        RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE, ASrcE;

  logic [3:0]  ALUControlE;
  logic [2:0]  funct3E;

  // Forwarding calculado en ID: lo que hoy esta en E estara en M y lo que
  // esta en M estara en W cuando esta instruccion llegue a EX (exmem y memwb
  // avanzan en cada ce). La seleccion sale de registro en EX
  logic [1:0]  ForwardAD, ForwardBD, ForwardADx;
  logic [4:0]  RdM;
  logic        RegWriteM;
  forwardunit fu (.Rs1E(rs1D), .Rs2E(rs2D), .RdM(RdE), .RdW(RdM),
                  .RegWriteM(RegWriteE), .RegWriteW(RegWriteM),
                  .ForwardAE(ForwardAD), .ForwardBE(ForwardBD));
  assign ForwardADx = CsrImmD ? 2'b00 : ForwardAD;

  logic [182:0] idexd_d, idexd_q;   // datos y control sin vaciar
  logic [9:0]   idexc_d, idexc_q;   // control que se vacia
  logic [3:0]   CauseE;
  logic         CsrWriteE, ExcE, MretE;

  assign idexd_d = {RD1Dop, RD2Dfix, ImmExtDx, PCD, PCPlus4D, rdD,
                    ForwardADx, ForwardBD, ALUSrcD, ASrcD, ALUControlD, funct3D,
                    CauseD, CsrWriteD};

  // No entra en EX nada de ID mientras se redirige a mtvec/mepc (RedirM) ni
  // en el ciclo siguiente (RedirMd: en ID queda una instruccion del camino
  // abandonado). Se anula aqui y no en FlushE para no alargar el camino
  // PCSrcE -> idexc. Una instruccion con excepcion puede llevar control (un
  // jalr ilegal salta), pero en MEM no escribe nada y redirige a mtvec
  logic RedirMd, IssueD;
  assign IssueD  = ValidD && !RedirM && !RedirMd;
  assign idexc_d = IssueD ? {RegWriteDx, MemWriteD, BranchD, JumpD, JalrD, ResultSrcDx,
                             ExcD, MretD, CsrD}
                          : 10'b0;

  floprec #(183) idexd (.clk(clk), .rst_n(rst_n), .ce(ce), .en(1'b1), .clr(1'b0),
                        .d(idexd_d), .q(idexd_q));
  floprc  #(10)  idexc (.clk(clk), .rst_n(rst_n), .ce(ce), .clr(FlushE),
                        .d(idexc_d), .q(idexc_q));

  logic [1:0]  ForwardAE, ForwardBE;
  assign {RD1E, RD2E, ImmExtE, PCE, PCPlus4E, RdE,
          ForwardAE, ForwardBE, ALUSrcE, ASrcE, ALUControlE, funct3E,
          CauseE, CsrWriteE} = idexd_q;
  assign {RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ResultSrcE,
          ExcE, MretE, CsrE} = idexc_q;

  // ================= Etapa EX =================
  logic [31:0] SrcAE, SrcBE, ALUResultE, WriteDataE;

  logic [31:0] FwdAE, FwdBE;
  logic [31:0] FwdValM;

  mux3 fwdamux (.d0(RD1E), .d1(ResultW), .d2(FwdValM), .sel3(ForwardAE), .y3(FwdAE));
  mux3 fwdbmux (.d0(RD2E), .d1(ResultW), .d2(FwdValM), .sel3(ForwardBE), .y3(FwdBE));

  mux2 srcamux (.d0(FwdAE), .d1(PCE),     .sel2(ASrcE),   .y2(SrcAE));
  mux2 srcbmux (.d0(FwdBE), .d1(ImmExtE), .sel2(ALUSrcE), .y2(SrcBE));

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

  // Excepciones de EX: destino de salto no alineado a 4 (el PC siempre lo
  // esta, asi que en branch y jal basta el bit 1 del inmediato) y acceso a
  // memoria no alineado. Se atienden en MEM, con valores de registro. Los dos
  // bits bajos de rs1 + imm (direccion y destino de jalr) salen de un sumador
  // propio: el resultado de la ALU llega tarde (pasa por el mux de SLT...)
  logic [1:0] AddrLowE;
  logic MisFetchE, MisAddrE, MisLoadE, MisStoreE, ExcXE;
  logic [3:0] CauseXE;
  assign AddrLowE  = FwdAE[1:0] + ImmExtE[1:0];
  assign MisFetchE = (((BranchE & TakenE) | JumpE) & ImmExtE[1]) | (JalrE & AddrLowE[1]);
  assign MisAddrE  = (funct3E[1:0] == 2'b10) ? (AddrLowE != 2'b00) :
                     (funct3E[1:0] == 2'b01) ?  AddrLowE[0] : 1'b0;
  assign MisLoadE  = (ResultSrcE == 2'b01) && MisAddrE;
  assign MisStoreE = MemWriteE && MisAddrE;
  assign ExcXE     = ExcE || MisFetchE || MisLoadE || MisStoreE;
  assign CauseXE   = ExcE ? CauseE : MisFetchE ? 4'd0 : MisLoadE ? 4'd4 : 4'd6;

  // Hueco de datos hacia MEM: dato del store, operando del CSR o destino de
  // branch/jal (para mtval si esta desalineado; el de jalr es ALUResultM)
  assign WriteDataE = CsrE              ? FwdAE     :
                      (BranchE | JumpE) ? PCTargetE : FwdBE;

  // ============== Registro EX/MEM ==============
  logic [31:0] ALUResultM, WriteDataM, PCPlus4M;

  logic        MemWriteM;
  logic [1:0]  ResultSrcM;
  logic [2:0]  funct3M;
  logic [148:0] exmem_d, exmem_q;
  logic         ExcM, MretM, CsrM, CsrWriteM, JalrM;
  logic [3:0]   CauseM;

  // El valor que se reenvia desde M se elige ya en EX: FwdValM sale de
  // registro y ResultSrcM no entra en el camino forwarding -> saltos
  logic [31:0] FwdValE;
  assign FwdValE = (ResultSrcE == 2'b11) ? ImmExtE :
                   (ResultSrcE == 2'b10) ? PCPlus4E : ALUResultE;

  // Con RedirM, lo que pasa de EX a MEM es del camino abandonado: burbuja
  logic OkE;
  assign OkE     = !RedirM;
  assign exmem_d = {ALUResultE, WriteDataE, PCPlus4E, FwdValE, RdE,
                    RegWriteE && OkE, MemWriteE && OkE, ResultSrcE, funct3E,
                    ExcXE && OkE, CauseXE, MretE && OkE, CsrE && OkE, CsrWriteE, JalrE};
  floprec #(149) exmem (.clk(clk), .rst_n(rst_n), .ce(ce), .en(1'b1), .clr(1'b0),
                        .d(exmem_d), .q(exmem_q));
  assign {ALUResultM, WriteDataM, PCPlus4M, FwdValM, RdM,
          RegWriteM, MemWriteM, ResultSrcM, funct3M,
          ExcM, CauseM, MretM, CsrM, CsrWriteM, JalrM} = exmem_q;

  // ================= Etapa MEM =================
  logic [31:0] MemWriteData, MemReadData, ReadDataM;
  logic [3:0]  ByteEn;

  storealign sa (.funct3(funct3M), .addr(ALUResultM[1:0]), .rs2_data(WriteDataM),
                 .write_data(MemWriteData), .byte_en(ByteEn));
  dmem dm (.clk(clk), .mem_write_en(MemWriteM & !ExcM & ce), .byte_en(ByteEn), .addr(ALUResultM),
           .write_data(MemWriteData), .read_data(MemReadData));
  loadext le (.funct3(funct3M), .addr(ALUResultM[1:0]), .mem_data(MemReadData),
              .read_data(ReadDataM));

  // El resultado se elige en MEM: ResultW sale directamente de un registro
  // y no hay mux delante del forwarding desde WB ni del banco de registros
  // Excepciones (precisas: lo anterior ya paso, lo posterior se descarta y
  // esta instruccion no escribe nada), mret y CSR
  logic [31:0] CsrRdataM, TvalM, MtvecM, MepcM;
  assign TvalM = (CauseM == 4'd4 || CauseM == 4'd6) ? ALUResultM :        // direccion
                 (CauseM == 4'd0) ? (JalrM ? {ALUResultM[31:1], 1'b0}     // destino
                                           : WriteDataM) :
                                    32'b0;
  csrfile csrs (.clk(clk), .rst_n(rst_n), .ce(ce),
                .csr_en(CsrM), .csr_we(CsrWriteM), .csr_addr(FwdValM[11:0]),
                .csr_op(funct3M[1:0]), .csr_wdata(WriteDataM), .csr_rdata(CsrRdataM),
                .trap(ExcM), .cause(CauseM), .tval(TvalM), .epc(PCPlus4M - 32'd4),
                .mret(MretM), .mtvec(MtvecM), .mepc(MepcM));

  assign RedirM       = ExcM || MretM;
  assign RedirTargetM = ExcM ? MtvecM : MepcM;
  floprec #(1) redirreg (.clk(clk), .rst_n(rst_n), .ce(ce), .en(1'b1), .clr(1'b0),
                         .d(RedirM), .q(RedirMd));

  logic [31:0] ResultM;
  assign ResultM = CsrM                  ? CsrRdataM :
                   (ResultSrcM == 2'b01) ? ReadDataM : FwdValM;

  // ============== Registro MEM/WB ==============
  logic [31:0] PCPlus4W;   // solo para las trazas (se elimina en sintesis)
  logic [69:0] memwb_d, memwb_q;

  assign memwb_d = {ResultM, PCPlus4M, RdM, RegWriteM && !ExcM};

  floprec #(70) memwb (.clk(clk), .rst_n(rst_n), .ce(ce), .en(1'b1), .clr(1'b0),
                       .d(memwb_d), .q(memwb_q));

  assign {ResultW, PCPlus4W, RdW, RegWriteW} = memwb_q;

  // ================= Etapa WB =================

  assign dbg    = ResultW;
  assign dbg_we = RegWriteW && (RdW != 0);

endmodule