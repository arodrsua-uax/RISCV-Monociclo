module tb_top_pipe;
  logic clk100 = 0, btn = 0;
  logic [3:0] led;

  top_pipe #(.DIV(4), .INIT_FILE("mem/suma.hex")) dut
    (.clk100(clk100), .btn(btn), .led(led));

  always #5 clk100 = ~clk100;

  always @(led) $display("%t led=%h", $time, led);

  initial begin
    $dumpfile("sim/top_pipe.vcd");
    $dumpvars(0, tb_top_pipe);
    btn = 1; #100;
    btn = 0;
    #20000;
    // suma.hex termina con lw x7 = 55 = 0x37: los LED se quedan en 7
    if (led == 4'h7) $display("tb_top_pipe: todos los tests pasan");
    else             $display("FALLO tb_top_pipe: led=%h, esperado 7", led);
    $finish;
  end
endmodule