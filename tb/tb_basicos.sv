// Prueba adder, mux2, mux3 y mux4
module tb_basicos;
  logic [31:0] a, b, sum;
  logic [7:0]  d0, d1, d2, d3, y2, y3, y4;
  logic        sel2;
  logic [1:0]  sel3, sel4;

  adder          dut_add  (a, b, sum);
  mux2 #(8)      dut_mux2 (d0, d1, sel2, y2);
  mux3 #(8)      dut_mux3 (d0, d1, d2, sel3, y3);
  mux4 #(8)      dut_mux4 (d0, d1, d2, d3, sel4, y4);

  initial begin
    $dumpfile("sim/basicos.vcd");
    $dumpvars(0, tb_basicos);
    // ---- adder ----
    a = 32'd4;        b = 32'd8;         #10;
    if (sum !== 32'd12)       $display("FALLO adder: 4+8 (sum=%h)", sum);

    a = 32'h0000_1000; b = 32'hFFFF_FFFC; #10;   // 0x1000 + (-4)
    if (sum !== 32'h0000_0FFC) $display("FALLO adder: suma con negativo (y=%h)", sum);

    a = 32'hFFFF_FFFF; b = 32'd1;         #10;   // desbordamiento
    if (sum !== 32'd0)        $display("FALLO adder: desbordamiento (y=%h)", sum);

    // ---- mux2 ----
    d0 = 8'h11; d1 = 8'h22; d2 = 8'h33;
    sel2 = 0; #10;
    if (y2 !== 8'h11) $display("FALLO mux2: sel=0 (y=%h)", y2);
    sel2 = 1; #10;
    if (y2 !== 8'h22) $display("FALLO mux2: sel=1 (y=%h)", y2);

    // ---- mux3 ----
    sel3 = 2'b00; #10;
    if (y3 !== 8'h11) $display("FALLO mux3: sel=00 (y=%h)", y3);
    sel3 = 2'b01; #10;
    if (y3 !== 8'h22) $display("FALLO mux3: sel=01 (y=%h)", y3);
    sel3 = 2'b10; #10;
    if (y3 !== 8'h33) $display("FALLO mux3: sel=10 (y=%h)", y3);

    // ---- mux4 ----
    d3 = 8'h44;
    sel4 = 2'b00; #10;
    if (y4 !== 8'h11) $display("FALLO mux4: sel=00 (y=%h)", y4);
    sel4 = 2'b01; #10;
    if (y4 !== 8'h22) $display("FALLO mux4: sel=01 (y=%h)", y4);
    sel4 = 2'b10; #10;
    if (y4 !== 8'h33) $display("FALLO mux4: sel=10 (y=%h)", y4);
    sel4 = 2'b11; #10;
    if (y4 !== 8'h44) $display("FALLO mux4: sel=11 (y=%h)", y4);

    $display("Test basicos terminado");
    $finish;
  end
endmodule
