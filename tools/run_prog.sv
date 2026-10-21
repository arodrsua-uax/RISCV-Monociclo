module run_prog;
  logic   clk = 0, rst_n;
  string  prog;
  integer cycles, i;


  riscv dut (.clk(clk), .rst_n(rst_n));


  always #5 clk = ~clk;

  // Traza: una línea por cada escritura visible para el programa
  always @(posedge clk)
    if (rst_n) begin
      if (dut.RegWrite && dut.Instr[11:7] != 0)
        $display("R pc=%h x%0d <= %h", dut.PC, dut.Instr[11:7], dut.dp.Result);
      if (dut.MemWrite)
        $display("M pc=%h [%h] <= %h mask=%b", dut.PC, dut.DataAdr, dut.MemWriteData, dut.ByteEn);
    end


  initial begin
    if (!$value$plusargs("prog=%s", prog)) begin
      $display("Uso: vvp sim/run_prog.vvp +prog=mem/x.hex [+cycles=N]");
      $finish;
    end
    if (!$value$plusargs("cycles=%d", cycles)) cycles = 200;

    // imem ya cargó su archivo por defecto en t=0: lo sustituimos en t=1
    rst_n = 0;
    #1;
    for (i = 0; i < 64; i = i + 1) dut.im.RAM[i] = 32'h00000013;  // nop
    for (i = 0; i < 64; i = i + 1) dut.dm.RAM[i] = 32'd0;         // dmem a 0
    $readmemh(prog, dut.im.RAM);
    #11;
    rst_n = 1;

    repeat (cycles) @(posedge clk);
    #1;

    $display("Programa: %0s   Ciclos: %0d   PC final = %h", prog, cycles, dut.PC);
    $display("--- registros ---");
    for (i = 0; i < 32; i = i + 4)
      $display("x%-2d=%h  x%-2d=%h  x%-2d=%h  x%-2d=%h",
               i,   dut.dp.rf.regfile_array[i],
               i+1, dut.dp.rf.regfile_array[i+1],
               i+2, dut.dp.rf.regfile_array[i+2],
               i+3, dut.dp.rf.regfile_array[i+3]);
    $display("--- memoria de datos (direccion: 4 palabras) ---");
    for (i = 0; i < 16; i = i + 4)
      $display("%02h: %h %h %h %h", i*4,
               dut.dm.RAM[i], dut.dm.RAM[i+1], dut.dm.RAM[i+2], dut.dm.RAM[i+3]);
    $finish;
  end
endmodule