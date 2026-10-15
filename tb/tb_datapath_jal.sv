module tb_datapath_jal;
  logic        clk = 0, rst_n;
  logic [1:0]  ResultSrc;
  logic        PCSrc, ALUSrc, RegWrite, MemWrite, Zero, Branch, Jump;
  logic [3:0]  ALUControl;
  logic [31:0] Instr, ReadData, PC, ALUResult, WriteData;

  // En el procesador real esto lo hara el controller
  assign PCSrc = Jump | (Branch & Zero);

  imem #(.INIT_FILE("mem/test_jal.hex")) im (.addr(PC), .instr(Instr));
  dmem dm (.clk(clk), .mem_write_en(MemWrite), .byte_en(4'b1111), .addr(ALUResult),
           .write_data(WriteData), .read_data(ReadData));

  datapath dut (
    .clk(clk), .rst_n(rst_n), .ResultSrc(ResultSrc), .PCSrc(PCSrc),
    .ALUSrc(ALUSrc), .ASrc(1'b0), .RegWrite(RegWrite), .ALUControl(ALUControl),
    .Instr(Instr), .ReadData(ReadData),
    .Zero(Zero), .PC(PC), .ALUResult(ALUResult), .WriteData(WriteData)
  );

  // Cables para ver en GTKWave
  wire [31:0] pctarget = dut.PCTarget;
  wire [31:0] x1 = dut.rf.regfile_array[1];
  wire [31:0] x4 = dut.rf.regfile_array[4];
  wire [31:0] x6 = dut.rf.regfile_array[6];

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  // Pone los controles y ejecuta UNA instruccion (un flanco de reloj)
  task ejecuta(input logic rw, input logic [1:0] rsrc, input logic jmp,
               input logic alusrc, input logic [3:0] ctl);
    RegWrite = rw; ResultSrc = rsrc; Jump = jmp;
    ALUSrc = alusrc; ALUControl = ctl;
    @(posedge clk); #1;
  endtask

  task chk_pc(input [31:0] esperado, input integer n);
    if (PC !== esperado)
      $display("FALLO PC %0d: PC=%h (esperado %h)", n, PC, esperado);
  endtask

  task chk(input integer r, input [31:0] esperado);
    if (dut.rf.regfile_array[r] !== esperado)
      $display("FALLO x%0d: %h (esperado %h)", r, dut.rf.regfile_array[r], esperado);
  endtask

  initial begin
    $dumpfile("sim/datapath_jal.vcd");
    $dumpvars(0, tb_datapath_jal);

    MemWrite = 0; Branch = 0; Jump = 0;
    RegWrite = 0; ResultSrc = 2'b00; ALUSrc = 0; ALUControl = 4'b0000;

    rst_n = 0; #12;
    rst_n = 1;

    //       RegWrite ResultSrc Jump ALUSrc ALUControl
    ejecuta(1, 2'b10, 1, 0, 4'b0000);  chk_pc(32'h08, 1);  // jal  x1, +8
    ejecuta(1, 2'b00, 0, 1, 4'b0000);  chk_pc(32'h0C, 2);  // addi x3, x0, 1
    ejecuta(1, 2'b10, 1, 0, 4'b0000);  chk_pc(32'h14, 3);  // jal  x4, +8
    ejecuta(1, 2'b10, 1, 0, 4'b0000);  chk_pc(32'h10, 4);  // jal  x6, -4
    ejecuta(1, 2'b00, 0, 1, 4'b0000);  chk_pc(32'h14, 5);  // addi x5, x0, 77

    chk(1, 32'h04);  chk(2, 32'd0);   chk(3, 32'd1);   // x2 = 0: se salto el addi
    chk(4, 32'h10);  chk(5, 32'd77);  chk(6, 32'h18);
    chk(0, 32'd0);

    $display("Test datapath jal terminado");
    $finish;
  end
endmodule