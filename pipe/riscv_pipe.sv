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


  assign RegWriteW = 1'b0;     // provisional
  assign RdW       = 5'd0;     // provisional
  assign ResultW   = 32'd0;    // provisional
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

  assign idex_d = {RD1D, RD2D, ImmExtD, PCD, PCPlus4D, rdD,
                   RegWriteD, MemWriteD, BranchD, JumpD, JalrD, ALUSrcD, ASrcD,
                   ResultSrcD, ALUControlD, funct3D};

  flopr #(181) idex (.clk(clk), .rst_n(rst_n), .d(idex_d), .q(idex_q));

  assign {RD1E, RD2E, ImmExtE, PCE, PCPlus4E, RdE,
          RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE, ASrcE,
          ResultSrcE, ALUControlE, funct3E} = idex_q;

endmodule