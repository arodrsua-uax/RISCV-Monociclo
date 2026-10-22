module tb_pipe_sys;
  logic clk = 0, rst_n;
  integer fallos = 0;
  logic halt1, halt2;

  // sys1: fence, ecall en la sombra de un salto tomado y ecall final
  // sys2: ebreak justo detras de un lw (lwStall por el campo rs2 = 1)
  riscv_pipe #(.INIT_FILE("mem/test_sys1.hex")) dut1 (.clk(clk), .rst_n(rst_n), .ce(1'b1),
                                                      .halt(halt1));
  riscv_pipe #(.INIT_FILE("mem/test_sys2.hex")) dut2 (.clk(clk), .rst_n(rst_n), .ce(1'b1),
                                                      .halt(halt2));

  always #5 clk = ~clk;

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/pipe_sys.vcd");
    $dumpvars(0, tb_pipe_sys);
    rst_n = 0; #12;
    rst_n = 1;

    chk(halt1, 1'b0, "halt1 inicio");
    chk(halt2, 1'b0, "halt2 inicio");

    // Margen de sobra: si halt no fuera fijo, lo de detras se ejecutaria
    repeat (60) @(posedge clk);
    #1;

    chk(halt1,                     1'b1,  "halt1");
    chk(dut1.rf.regfile_array[1],  32'd5, "x1");
    chk(dut1.rf.regfile_array[2],  32'd6, "x2 tras fence");
    chk(dut1.rf.regfile_array[3],  32'd3, "x3 sombra");
    chk(dut1.rf.regfile_array[4],  32'd6, "x4 antes ecall");
    chk(dut1.rf.regfile_array[5],  32'd0, "x5 tras ecall");
    chk(dut1.dm.RAM[0],            32'd6, "RAM[0]");
    chk(dut1.dm.RAM[1],            32'hx, "RAM[1] sin sw");   // nunca escrita

    chk(halt2,                     1'b1,  "halt2");
    chk(dut2.rf.regfile_array[1],  32'd9, "x1 lw");
    chk(dut2.rf.regfile_array[2],  32'd0, "x2 tras ebreak");

    if (fallos == 0) $display("pipe_sys: todos los tests pasan");
    else             $display("pipe_sys: %0d fallos", fallos);
    $finish;
  end
endmodule
