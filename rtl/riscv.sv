// riscv.sv: procesador RISC-V monociclo completo.
// Une controller, datapath y las memorias de instrucciones y de datos.
// Las salidas solo sirven para observar el procesador desde el testbench.
module riscv #(
  parameter INIT_FILE = "mem/imem.hex"   // programa que carga la imem
)(
  input  logic        clk,
  input  logic        rst_n,
  output logic [31:0] PC,
  output logic [31:0] Instr,
  output logic [31:0] DataAdr,           // dirección de la dmem (ALUResult)
  output logic [31:0] WriteData,         // rs2, antes de alinear para sb/sh
  output logic        MemWrite
);

  // Señales internas entre controller y datapath
  logic        RegWrite, ALUSrc, ASrc, Zero;
  logic [1:0]  PCSrc, ResultSrc;
  logic [3:0]  ALUControl;
  logic [31:0] ReadData;

  // Señales internas entre el procesador y la dmem (accesos de byte y media palabra)
  logic [31:0] MemWriteData, MemReadData;
  logic [3:0]  ByteEn;

  controller ctrl (
    .instr(Instr), .Zero(Zero),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .ASrc(ASrc), .PCSrc(PCSrc),
    .ResultSrc(ResultSrc), .ALUControl(ALUControl)
  );

  datapath dp (
    .clk(clk), .rst_n(rst_n), .ResultSrc(ResultSrc), .PCSrc(PCSrc),
    .ALUSrc(ALUSrc), .ASrc(ASrc), .RegWrite(RegWrite), .ALUControl(ALUControl),
    .Instr(Instr), .ReadData(ReadData),
    .Zero(Zero), .PC(PC), .ALUResult(DataAdr), .WriteData(WriteData)
  );

  imem #(.INIT_FILE(INIT_FILE)) im (.addr(PC), .instr(Instr));

  // funct3 (Instr[14:12]) indica el tamaño del acceso y, en los loads, el tipo de extensión
  storealign sa (.funct3(Instr[14:12]), .addr(DataAdr[1:0]), .rs2_data(WriteData),
                 .write_data(MemWriteData), .byte_en(ByteEn));

  loadext le (.funct3(Instr[14:12]), .addr(DataAdr[1:0]), .mem_data(MemReadData),
              .read_data(ReadData));

  // MemWrite va del controller directamente a la dmem, sin pasar por el datapath
  dmem dm (.clk(clk), .mem_write_en(MemWrite), .byte_en(ByteEn), .addr(DataAdr),
           .write_data(MemWriteData), .read_data(MemReadData));

endmodule
