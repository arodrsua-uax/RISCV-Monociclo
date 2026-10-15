module tb_datapath;
  logic        clk = 0, rst_n;
  logic [1:0]  ResultSrc;
  logic        PCSrc, ALUSrc, RegWrite, MemWrite, Zero;
  logic [3:0]  ALUControl;
  logic [31:0] Instr, ReadData, PC, ALUResult, WriteData;

  imem #(.INIT_FILE("mem/test_dp.hex")) im (.addr(PC), .instr(Instr));
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
    $dumpfile("sim/datapath.vcd");
    $dumpvars(0, tb_datapath);

    // Controles de lw
    ResultSrc = 2'b01; PCSrc = 0; ALUSrc = 1;
    RegWrite = 1; MemWrite = 0; ALUControl = 4'b0000;

    // Datos en dmem (palabras 2 y 3 = direcciones 8 y 12)
    dm.RAM[2] = 32'h11111111;
    dm.RAM[3] = 32'h22222222;

    rst_n = 0; #12;
    rst_n = 1;
    #4;   // t=16: ya paso el flanco de t=15 (ejecuto lw x5)
    if (PC !== 32'd4)                          $display("FALLO 1: PC=%h (esperado 4)", PC);
    if (dut.rf.regfile_array[5] !== 32'h11111111)
                                               $display("FALLO 2: x5=%h", dut.rf.regfile_array[5]);
    if (ALUResult !== 32'd12)                  $display("FALLO 3: ALUResult=%h (esperado 12)", ALUResult);

    #10;  // t=26: ya paso el flanco de t=25 (ejecuto lw x6)
    if (PC !== 32'd8)                          $display("FALLO 4: PC=%h (esperado 8)", PC);
    if (dut.rf.regfile_array[6] !== 32'h22222222)
                                               $display("FALLO 5: x6=%h", dut.rf.regfile_array[6]);

    $display("Test datapath terminado");
    $finish;
  end
endmodule