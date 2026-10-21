module run_pipe;
  logic   clk = 0, rst_n;
  string  prog;
  integer cycles, i;

  riscv_pipe dut (.clk(clk), .rst_n(rst_n));

  always #5 clk = ~clk;

  initial begin
    if (!$value$plusargs("prog=%s", prog)) begin
      $display("Uso: vvp sim/cmp_pipe.vvp +prog=mem/x.hex [+cycles=N]");
      $finish;
    end
    if (!$value$plusargs("cycles=%d", cycles)) cycles = 400;

    rst_n = 0;
    #1;
    for (i = 0; i < 64; i = i + 1) dut.im.RAM[i] = 32'h00000013;  // nop
    $readmemh(prog, dut.im.RAM);
    #11;
    rst_n = 1;

    repeat (cycles) @(posedge clk);
    $finish;
  end

  // Traza con el mismo formato que el monociclo
  always @(posedge clk)
    if (rst_n) begin
      if (dut.RegWriteW && dut.RdW != 0)
        $display("R pc=%h x%0d <= %h", dut.PCPlus4W - 32'd4, dut.RdW, dut.ResultW);
      if (dut.MemWriteM)
        $display("M pc=%h [%h] <= %h mask=%b",
                 dut.PCPlus4M - 32'd4, dut.ALUResultM, dut.MemWriteData, dut.ByteEn);
    end
endmodule