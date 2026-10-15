module tb_datapath_sw;
  logic        clk = 0, rst_n;
  logic [1:0]  ResultSrc;
  logic        PCSrc, ALUSrc, RegWrite, MemWrite, Zero;
  logic [3:0]  ALUControl;
  logic [31:0] Instr, ReadData, PC, ALUResult, WriteData;

  wire [31:0] ram2 = dm.RAM[2];
  wire [31:0] ram3 = dm.RAM[3];
  wire [31:0] ram4 = dm.RAM[4];
  
  imem #(.INIT_FILE("mem/test_sw.hex")) im (.addr(PC), .instr(Instr));
  dmem dm (.clk(clk), .mem_write_en(MemWrite), .byte_en(4'b1111), .addr(ALUResult),
           .write_data(WriteData), .read_data(ReadData));

  datapath dut (
    .clk(clk), .rst_n(rst_n), .ResultSrc(ResultSrc), .PCSrc(PCSrc),
    .ALUSrc(ALUSrc), .ASrc(1'b0), .RegWrite(RegWrite), .ALUControl(ALUControl),
    .Instr(Instr), .ReadData(ReadData),
    .Zero(Zero), .PC(PC), .ALUResult(ALUResult), .WriteData(WriteData)
  );

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  initial begin
    $dumpfile("sim/datapath_sw.vcd");
    $dumpvars(0, tb_datapath_sw);

    // Controles de sw (MemWrite se activa despues del reset)
    ResultSrc = 2'b00; PCSrc = 0; ALUSrc = 1;
    RegWrite = 0; MemWrite = 0; ALUControl = 4'b0000;

    rst_n = 0; #12;
    rst_n = 1;

    // Precargar registros (despues del reset, que los pone a 0)
    dut.rf.regfile_array[5] = 32'hAAAA0005;
    dut.rf.regfile_array[6] = 32'hBBBB0006;
    dut.rf.regfile_array[7] = 32'd20;
    MemWrite = 1;

    #4;   // t=16: ya paso el flanco de t=15 (ejecuto sw x5, 8(x0))
    if (dm.RAM[2] !== 32'hAAAA0005) $display("FALLO 1: RAM[2]=%h", dm.RAM[2]);
    if (PC !== 32'd4)               $display("FALLO 2: PC=%h (esperado 4)", PC);
    // ahora esta presente la 2a instruccion: sw x6, 12(x0)
    if (ALUResult !== 32'd12)       $display("FALLO 3: ALUResult=%h (esperado 12)", ALUResult);
    if (WriteData !== 32'hBBBB0006) $display("FALLO 4: WriteData=%h", WriteData);

    #10;  // t=26: ya paso el flanco de t=25 (ejecuto sw x6, 12(x0))
    if (dm.RAM[3] !== 32'hBBBB0006) $display("FALLO 5: RAM[3]=%h", dm.RAM[3]);

    #10;  // t=36: ya paso el flanco de t=35 (ejecuto sw x6, -4(x7))
    if (dm.RAM[4] !== 32'hBBBB0006) $display("FALLO 6: RAM[4]=%h", dm.RAM[4]);

    // sw no debe modificar registros
    if (dut.rf.regfile_array[5] !== 32'hAAAA0005) $display("FALLO 7: x5 cambio");
    if (dut.rf.regfile_array[6] !== 32'hBBBB0006) $display("FALLO 8: x6 cambio");

    #20;
    $display("Test datapath sw terminado");
    $finish;
  end
endmodule