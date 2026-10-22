module tb_pipe_ce;
  logic clk = 0, rst_n, ce = 0, ce_at_edge = 0;
  integer fallos = 0, k = 0;
  logic [31:0] pc_prev_neg;

  riscv_pipe #(.INIT_FILE("mem/test_pipe6.hex")) dut
    (.clk(clk), .rst_n(rst_n), .ce(ce));

  always #5 clk = ~clk;

  // ce vale 1 durante un ciclo de cada 3
  always @(posedge clk) begin
    k          <= (k == 2) ? 0 : k + 1;
    ce         <= (k == 1);
    ce_at_edge <= ce;           // valor de ce que vio el DUT en este flanco
  end

  // Si ce valia 0 en el ultimo flanco, el PC no puede haber cambiado
  always @(negedge clk) if (rst_n) begin
    if (!ce_at_edge && !$isunknown(pc_prev_neg) && dut.PCF !== pc_prev_neg) begin
      $display("FALLO: el PC cambio sin ce (%h -> %h)", pc_prev_neg, dut.PCF);
      fallos = fallos + 1;
    end
    pc_prev_neg = dut.PCF;
  end

  task chk(input [31:0] valor, input [31:0] esperado, input [8*16-1:0] nombre);
    if (valor !== esperado) begin
      $display("FALLO %0s: %h (esperado %h)", nombre, valor, esperado);
      fallos = fallos + 1;
    end
  endtask

  initial begin
    $dumpfile("sim/pipe_ce.vcd");
    $dumpvars(0, tb_pipe_ce);
    rst_n = 0; #12;
    rst_n = 1;
    repeat (160) @(posedge clk);
    #1;
    chk(dut.rf.regfile_array[3],  32'd14, "x3");
    chk(dut.rf.regfile_array[6],  32'd8,  "x6");
    chk(dut.rf.regfile_array[10], 32'd1,  "x10");
    chk(dut.dm.RAM[0],            32'd7,  "RAM[0]");
    chk(dut.dm.RAM[1],            32'd7,  "RAM[1]");
    if (fallos == 0) $display("pipe_ce: todos los tests pasan");
    else             $display("pipe_ce: %0d fallos", fallos);
    $finish;
  end
endmodule