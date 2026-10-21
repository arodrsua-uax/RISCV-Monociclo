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
  // Campos de la instrucción (todavía solo se miran, no se usan)
  logic [6:0] opD, funct7D;
  logic [2:0] funct3D;
  logic [4:0] rs1D, rs2D, rdD;

  assign opD     = InstrD[6:0];
  assign rdD     = InstrD[11:7];
  assign funct3D = InstrD[14:12];
  assign rs1D    = InstrD[19:15];
  assign rs2D    = InstrD[24:20];
  assign funct7D = InstrD[31:25];

endmodule