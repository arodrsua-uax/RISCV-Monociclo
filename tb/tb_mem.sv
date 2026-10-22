module tb_mem;
  logic        clk = 0, mem_write_en;
  logic [31:0] a_i, rd_i;
  logic [31:0] a_d, write_data, rd_d;

  imem #(.INIT_FILE("mem/test_imem.hex")) dut_i (.addr(a_i), .instr(rd_i));
  dmem dut_d (clk, mem_write_en, 4'b1111, a_d, write_data, rd_d);

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  initial begin
    $dumpfile("sim/mem.vcd");
    $dumpvars(0, tb_mem);

    // ---------- imem ----------
    a_i = 32'd0;  #1;
    if (rd_i !== 32'h00500093) $display("FALLO I1: palabra 0 (rd=%h)", rd_i);
    a_i = 32'd4;  #1;
    if (rd_i !== 32'h00300113) $display("FALLO I2: palabra 1 (rd=%h)", rd_i);
    a_i = 32'd8;  #1;
    if (rd_i !== 32'h002081B3) $display("FALLO I3: palabra 2 (rd=%h)", rd_i);
    a_i = 32'd12; #1;
    if (rd_i !== 32'h00302223) $display("FALLO I4: palabra 3 (rd=%h)", rd_i);
    a_i = 32'd5;  #1;   // direccion no alineada: usa la palabra 1
    if (rd_i !== 32'h00300113) $display("FALLO I5: a[1:0] debe ignorarse (rd=%h)", rd_i);

    // ---------- dmem ----------
     @(negedge clk);          // esperar a t=10, lejos de un flanco de subida
    mem_write_en = 1; a_d = 32'd0; write_data = 32'hDEADBEEF; #1;
    if (rd_d === 32'hDEADBEEF) $display("FALLO D1: escritura asincrona");
    @(posedge clk); #1;
    mem_write_en = 0;
    if (rd_d !== 32'hDEADBEEF) $display("FALLO D2: no se escribio (rd=%h)", rd_d);

    mem_write_en = 1; a_d = 32'd4; write_data = 32'h12345678;
    @(posedge clk); #1;
    mem_write_en = 0; a_d = 32'd0; #1;
    if (rd_d !== 32'hDEADBEEF) $display("FALLO D3: palabra 0 se corrompio (rd=%h)", rd_d);
    a_d = 32'd4; #1;
    if (rd_d !== 32'h12345678) $display("FALLO D4: palabra 1 (rd=%h)", rd_d);

    mem_write_en = 0; a_d = 32'd0; write_data = 32'hAAAAAAAA;
    @(posedge clk); #1;
    if (rd_d !== 32'hDEADBEEF) $display("FALLO D5: escribio con mem_write_en=0 (rd=%h)", rd_d);

    a_d = 32'd7; #1;    // direccion no alineada: usa la palabra 1
    if (rd_d !== 32'h12345678) $display("FALLO D6: a[1:0] debe ignorarse (rd=%h)", rd_d);

    $display("Test mem terminado");
    $finish;
  end
endmodule