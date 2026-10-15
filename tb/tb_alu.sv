module tb_alu;
  logic [31:0] a, b, result;
  logic [3:0]  alucontrol;
  logic        zero;

  alu dut (a, b, alucontrol, result, zero);

  task check(input [31:0] x, input [31:0] y, input [3:0] ctl,
             input [31:0] esperado, input esperado_zero, input integer n);
    a = x; b = y; alucontrol = ctl; #10;
    if (result !== esperado || zero !== esperado_zero)
      $display("FALLO %0d: result=%h (esperado %h) zero=%b (esperado %b)",
               n, result, esperado, zero, esperado_zero);
  endtask

  initial begin
    $dumpfile("sim/alu.vcd");
    $dumpvars(0, tb_alu);

    //    a             b             ctl     esperado      zero  n
    check(32'd5,        32'd3,        3'b000, 32'd8,        1'b0, 1);   // add
    check(32'hFFFFFFFF, 32'd1,        3'b000, 32'd0,        1'b1, 2);   // add con acarreo
    check(32'd10,       32'd3,        3'b001, 32'd7,        1'b0, 3);   // sub
    check(32'd5,        32'd5,        3'b001, 32'd0,        1'b1, 4);   // sub, zero=1
    check(32'd3,        32'd5,        3'b001, 32'hFFFFFFFE, 1'b0, 5);   // sub negativo
    check(32'hF0F0F0F0, 32'h0FF00FF0, 3'b010, 32'h00F000F0, 1'b0, 6);   // and
    check(32'hF0F0F0F0, 32'h0FF00FF0, 3'b011, 32'hFFF0FFF0, 1'b0, 7);   // or
    check(32'hFFFFFFFF, 32'd1,        3'b101, 32'd1,        1'b0, 8);   // slt: -1 < 1
    check(32'd1,        32'hFFFFFFFF, 3'b101, 32'd0,        1'b1, 9);   // slt: 1 < -1
    check(32'd3,        32'd5,        3'b101, 32'd1,        1'b0, 10);  // slt: 3 < 5
    check(32'd5,        32'd5,        3'b101, 32'd0,        1'b1, 11);  // slt: 5 < 5
    check(32'd5,        32'd3,        3'b101, 32'd0,        1'b1, 12);  // slt: 5 < 3
    check(32'h80000000, 32'd1,        3'b101, 32'd1,        1'b0, 13);  // slt con desbordamiento
    check(32'hF0F0F0F0, 32'h0FF00FF0, 4'b1000, 32'hFF00FF00, 1'b0, 14); // xor
    check(32'd1,        32'd4,        4'b1001, 32'd16,        1'b0, 15); // sll
    check(32'h80000000, 32'd4,        4'b1010, 32'h08000000,  1'b0, 16); // srl
    check(32'h80000000, 32'd4,        4'b1011, 32'hF8000000,  1'b0, 17); // sra (extiende signo)
    check(32'hFFFFFFFF, 32'd1,        4'b1100, 32'd0,         1'b1, 18); // sltu: 0xFFFFFFFF < 1 es falso
    check(32'd1,        32'hFFFFFFFF, 4'b1100, 32'd1,         1'b0, 19); // sltu: 1 < 0xFFFFFFFF es cierto
   
    $display("Test alu terminado");
    $finish;
  end
endmodule