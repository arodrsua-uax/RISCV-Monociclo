module tb_top_fpga;
  logic clk100 = 0, btn = 0;
  logic [3:0] led;

  top_fpga #(.DIV_BITS(2), .INIT_FILE("mem/suma.hex")) dut
    (.clk100(clk100), .btn(btn), .led(led));

  always #5 clk100 = ~clk100;

  initial begin
    $dumpfile("sim/top_fpga.vcd");
    $dumpvars(0, tb_top_fpga);
    btn = 1; #100;   // mantener reset
    btn = 0;
    #5000;
    $finish;
  end
endmodule