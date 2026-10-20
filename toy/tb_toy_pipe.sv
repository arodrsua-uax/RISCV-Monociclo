module tb_toy_pipe;
  logic        clk = 0, rst_n;
  logic [31:0] x, result;
  integer      fallos = 0;

  toy_pipe dut (.clk(clk), .rst_n(rst_n), .x(x), .result(result));

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25, ...

  task chk(input [31:0] esperado, input integer n);
    if (result !== esperado) begin
      $display("FALLO %0d: result=%0d (esperado %0d)", n, result, esperado);
      fallos = fallos + 1;
    end
  endtask

  // Bloque 1: un número nuevo en x cada ciclo
  initial begin
    x = 0;
    #12 x = 10;
    #8  x = 20;   // t=20
    #10 x = 30;   // t=30
    #10 x = 40;   // t=40
    #10 x = 0;    // t=50
  end

  // Bloque 2: reset y comprobaciones
  initial begin
    $dumpfile("sim/toy_pipe.vcd");
    $dumpvars(0, tb_toy_pipe);
    rst_n = 0; #12;
    rst_n = 1;
    #24 chk(19, 1);   // t=36: sale (10+1)*2-3
    #10 chk(39, 2);   // t=46: (20+1)*2-3
    #10 chk(59, 3);   // t=56: (30+1)*2-3
    #10 chk(79, 4);   // t=66: (40+1)*2-3
    if (fallos == 0) $display("toy_pipe: todos los tests pasan");
    else             $display("toy_pipe: %0d fallos", fallos);
    $finish;
  end
endmodule