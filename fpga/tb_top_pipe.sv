module tb_top_pipe;
  logic clk100 = 0, btn = 0;
  logic [3:0] led;

  top_pipe #(.DIV(4), .INIT_FILE("mem/suma.hex")) dut
    (.clk100(clk100), .btn(btn), .led(led));

  always #5 clk100 = ~clk100;

  initial begin
    $dumpfile("sim/top_pipe.vcd");
    $dumpvars(0, tb_top_pipe);
    btn = 1; #100;
    btn = 0;
    #20000;
    $finish;
  end
endmodule