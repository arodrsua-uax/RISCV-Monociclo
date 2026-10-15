module tb_datapath_r;
  logic        clk = 0, rst_n;
  logic [1:0]  ResultSrc;
  logic        PCSrc, ALUSrc, RegWrite, MemWrite, Zero;
  logic [3:0]  ALUControl;
  logic [31:0] Instr, ReadData, PC, ALUResult, WriteData;

  imem #(.INIT_FILE("mem/test_r.hex")) im (.addr(PC), .instr(Instr));
  dmem dm (.clk(clk), .mem_write_en(MemWrite), .byte_en(4'b1111), .addr(ALUResult),
           .write_data(WriteData), .read_data(ReadData));

  datapath dut (
    .clk(clk), .rst_n(rst_n), .ResultSrc(ResultSrc), .PCSrc(PCSrc),
    .ALUSrc(ALUSrc), .ASrc(1'b0), .RegWrite(RegWrite), .ALUControl(ALUControl),
    .Instr(Instr), .ReadData(ReadData),
    .Zero(Zero), .PC(PC), .ALUResult(ALUResult), .WriteData(WriteData)
  );

  // Cables para ver registros en GTKWave
  wire [31:0] x3 = dut.rf.regfile_array[3];
  wire [31:0] x4 = dut.rf.regfile_array[4];
  wire [31:0] x14 = dut.rf.regfile_array[14];

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  // Pone los controles y ejecuta UNA instruccion (un flanco de reloj)
  task ejecuta(input logic alusrc, input logic [3:0] ctl);
    ALUSrc = alusrc; ALUControl = ctl;
    @(posedge clk); #1;
  endtask

  task chk(input integer n, input [31:0] esperado);
    if (dut.rf.regfile_array[n] !== esperado)
      $display("FALLO x%0d: %h (esperado %h)", n, dut.rf.regfile_array[n], esperado);
  endtask

  initial begin
    $dumpfile("sim/datapath_r.vcd");
    $dumpvars(0, tb_datapath_r);

    // Controles comunes a R e I aritmetica
    ResultSrc = 2'b00; PCSrc = 0; RegWrite = 1; MemWrite = 0;
    ALUSrc = 1; ALUControl = 4'b0000;

    rst_n = 0; #12;
    rst_n = 1;

    //       ALUSrc  ALUControl
    ejecuta(1, 4'b0000);   //  1: addi x1, x0, 5
    ejecuta(1, 4'b0000);   //  2: addi x2, x0, 3
    ejecuta(0, 4'b0000);   //  3: add  x3, x1, x2
    ejecuta(0, 4'b0001);   //  4: sub  x4, x1, x2
    ejecuta(0, 4'b0010);   //  5: and  x5, x1, x2
    ejecuta(0, 4'b0011);   //  6: or   x6, x1, x2
    ejecuta(0, 4'b0101);   //  7: slt  x7, x1, x2
    ejecuta(0, 4'b0101);   //  8: slt  x8, x2, x1
    ejecuta(1, 4'b0000);   //  9: addi x9, x1, -1
    ejecuta(1, 4'b0010);   // 10: andi x10, x1, 6
    ejecuta(1, 4'b0011);   // 11: ori  x11, x1, 2
    ejecuta(1, 4'b0101);   // 12: slti x12, x1, 10
    ejecuta(1, 4'b0000);   // 13: addi x13, x0, -1
    ejecuta(0, 4'b0101);   // 14: slt  x14, x13, x1

    if (PC !== 32'd56) $display("FALLO PC=%h (esperado 38)", PC);
    chk(1, 32'd5);   chk(2, 32'd3);   chk(3, 32'd8);   chk(4, 32'd2);
    chk(5, 32'd1);   chk(6, 32'd7);   chk(7, 32'd0);   chk(8, 32'd1);
    chk(9, 32'd4);   chk(10, 32'd4);  chk(11, 32'd7);  chk(12, 32'd1);
    chk(13, 32'hFFFFFFFF);            chk(14, 32'd1);
    chk(0, 32'd0);   // x0 sigue valiendo 0

    $display("Test datapath R/I terminado");
    $finish;
  end
endmodule