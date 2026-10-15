module tb_datapath_beq;
  logic        clk = 0, rst_n;
  logic [1:0]  ResultSrc;
  logic        PCSrc, ALUSrc, RegWrite, MemWrite, Zero, Branch;
  logic [3:0]  ALUControl;
  logic [31:0] Instr, ReadData, PC, ALUResult, WriteData;

  // En el procesador real esto lo hara el controller
  assign PCSrc = Branch & Zero;

  imem #(.INIT_FILE("mem/test_beq.hex")) im (.addr(PC), .instr(Instr));
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
  wire [31:0] x3 = dut.rf.regfile_array[3];
  wire [31:0] x8 = dut.rf.regfile_array[8];

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  // Pone los controles y ejecuta UNA instruccion (un flanco de reloj)
  task ejecuta(input logic rw, input logic alusrc,
               input logic [3:0] ctl, input logic br);
    RegWrite = rw; ALUSrc = alusrc; ALUControl = ctl; Branch = br;
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
    $dumpfile("sim/datapath_beq.vcd");
    $dumpvars(0, tb_datapath_beq);

    ResultSrc = 2'b00; MemWrite = 0; Branch = 0;
    RegWrite = 0; ALUSrc = 0; ALUControl = 4'b0000;

    rst_n = 0; #12;
    rst_n = 1;

    //       RegWrite ALUSrc ALUControl Branch
    ejecuta(1, 1, 4'b0000, 0);  chk_pc(32'h04, 1);   // addi x1, x0, 5
    ejecuta(1, 1, 4'b0000, 0);  chk_pc(32'h08, 2);   // addi x2, x0, 5
    ejecuta(0, 0, 4'b0001, 1);  chk_pc(32'h10, 3);   // beq x1,x2,+8  (salta)
    ejecuta(1, 1, 4'b0000, 0);  chk_pc(32'h14, 4);   // addi x4, x0, 1
    ejecuta(1, 1, 4'b0000, 0);  chk_pc(32'h18, 5);   // addi x5, x0, 7
    ejecuta(0, 0, 4'b0001, 1);  chk_pc(32'h1C, 6);   // beq x1,x5,+8  (no salta)
    ejecuta(1, 1, 4'b0000, 0);  chk_pc(32'h20, 7);   // addi x6, x0, 2
    ejecuta(0, 0, 4'b0001, 1);  chk_pc(32'h28, 8);   // beq x0,x0,+8  (salta)
    ejecuta(0, 0, 4'b0001, 1);  chk_pc(32'h24, 9);   // beq x0,x0,-4  (hacia atras)
    ejecuta(1, 1, 4'b0000, 0);  chk_pc(32'h28, 10);  // addi x8, x0, 42

    chk(1, 32'd5);  chk(2, 32'd5);  chk(3, 32'd0);   // x3 = 0: se salto el addi
    chk(4, 32'd1);  chk(5, 32'd7);  chk(6, 32'd2);
    chk(8, 32'd42); chk(0, 32'd0);

    $display("Test datapath beq terminado");
    $finish;
  end
endmodule