module tb_pipe2;
  logic clk = 0, rst_n;
  integer fallos = 0;

  riscv_pipe #(.INIT_FILE("mem/test_imem.hex")) dut (.clk(clk), .rst_n(rst_n), .ce(1'b1));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/pipe2.vcd");
    $dumpvars(0, tb_pipe2);

    rst_n = 0; #12;
    rst_n = 1;
    // Precargar x1 y x2 (despues del reset, que los pone a 0)
    dut.rf.regfile_array[1] = 32'd5;
    dut.rf.regfile_array[2] = 32'd3;

    @(posedge clk); #1;   // t=16: addi x1 esta en ID
    chk(dut.ALUSrcD,     32'd1, "ALUSrcD addi");
    chk(dut.RegWriteD,   32'd1, "RegWriteD addi");
    chk(dut.ImmExtD,     32'd5, "ImmExtD addi");
    chk(dut.rdD,         32'd1, "rdD addi");

    @(posedge clk); #1;   // t=26: addi x1 pasa a EX; addi x2 esta en ID
    chk(dut.ImmExtE,     32'd5, "ImmExtE");
    chk(dut.RdE,         32'd1, "RdE");
    chk(dut.RegWriteE,   32'd1, "RegWriteE");
    chk(dut.ImmExtD,     32'd3, "ImmExtD addi 2");

    @(posedge clk); #1;   // t=36: add x3,x1,x2 esta en ID
    chk(dut.RD1D,        32'd5, "RD1D add");
    chk(dut.RD2D,        32'd3, "RD2D add");
    chk(dut.ALUSrcD,     32'd0, "ALUSrcD add");
    chk(dut.ALUControlD, 32'd0, "ALUControlD add");

    @(posedge clk); #1;   // t=46: add pasa a EX; sw esta en ID
    chk(dut.RD1E,        32'd5, "RD1E add");
    chk(dut.RD2E,        32'd3, "RD2E add");
    chk(dut.RdE,         32'd3, "RdE add");
    chk(dut.MemWriteD,   32'd1, "MemWriteD sw");
    chk(dut.RegWriteD,   32'd0, "RegWriteD sw");
    chk(dut.ImmExtD,     32'd4, "ImmExtD sw");

    if (fallos == 0) $display("pipe2: todos los tests pasan");
    else             $display("pipe2: %0d fallos", fallos);
    $finish;
  end
endmodule