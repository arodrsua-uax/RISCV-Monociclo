module tb_flopr;
  logic       clk = 0, rst_n;
  logic [31:0] d, q;

  flopr #(32) dut (clk, rst_n, d, q);

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  initial begin
    $dumpfile("sim/flopr.vcd");
    $dumpvars(0, tb_flopr);

    rst_n = 0; d = 8'hA5; #12;
    if (q !== 32'h00) $display("FALLO: reset no pone q a 0 (q=%h)", q);

    rst_n = 1; #10;                      // el flanco en t=15 captura A5
    if (q !== 32'hA5) $display("FALLO: no captura d (q=%h)", q);

    d = 8'h3C; #10;                       // el flanco en t=25 captura 3C
    if (q !== 32'h3C) $display("FALLO: segundo dato (q=%h)", q);

    rst_n = 0; #1;                       // reset asincrono: sin esperar flanco
    if (q !== 32'h00) $display("FALLO: reset asincrono (q=%h)", q);

    $display("Test flopr terminado");
    $finish;
  end
endmodule