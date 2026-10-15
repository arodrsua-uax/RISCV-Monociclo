module tb_regfile;
  logic        clk = 0, rd_write_en, rst_n = 1;
  logic [4:0]  rs1_addr, rs2_addr, rd_addr;
  logic [31:0] rd_data, rs1_data, rs2_data;

  regfile dut (.clk, .rst_n, .rd_write_en, .rs1_addr, .rs2_addr, .rd_addr, .rd_data, .rs1_data, .rs2_data);

  always #5 clk = ~clk;   // flancos de subida en t=5, 15, 25...

  initial begin
    $dumpfile("sim/regfile.vcd");
    $dumpvars(0, tb_regfile);

    rd_write_en = 0; rs1_addr = 0; rs2_addr = 0; rd_addr = 0; rd_data = 0;

    // 0. Reset: registros a 0 (rst_n activo en bajo)
    rst_n = 0;
    @(posedge clk); #1;      // mantenemos el reset durante un flanco
    rst_n = 1;

    rs1_addr = 5'd7; rs2_addr = 5'd31; #1;
    if (rs1_data !== 32'h0) $display("FALLO 0a: x7 no es 0 tras reset (rs1_data=%h)", rs1_data);
    if (rs2_data !== 32'h0) $display("FALLO 0b: x31 no es 0 tras reset (rs2_data=%h)", rs2_data);

    // 1. Escribir x5 y leerlo por el puerto 1
    rd_write_en = 1; rd_addr = 5'd5; rd_data = 32'hDEADBEEF;
    @(posedge clk); #1;
    rd_write_en = 0; rs1_addr = 5'd5; #1;
    if (rs1_data !== 32'hDEADBEEF) $display("FALLO 1: lectura x5 (rs1_data=%h)", rs1_data);

    // 2. Escribir x10 y leer x5 y x10 a la vez
    rd_write_en = 1; rd_addr = 5'd10; rd_data = 32'h12345678;
    @(posedge clk); #1;
    rd_write_en = 0; rs1_addr = 5'd5; rs2_addr = 5'd10; #1;
    if (rs1_data !== 32'hDEADBEEF) $display("FALLO 2a: rs1_data=%h", rs1_data);
    if (rs2_data !== 32'h12345678) $display("FALLO 2b: rs2_data=%h", rs2_data);

    // 3. Con rd_write_en=0 no se debe escribir
    rd_write_en = 0; rd_addr = 5'd5; rd_data = 32'hAAAAAAAA;
    @(posedge clk); #1;
    if (rs1_data !== 32'hDEADBEEF) $display("FALLO 3: escribio con rd_write_en=0 (rs1_data=%h)", rs1_data);

    // 4. x0 siempre vale 0
    rd_write_en = 1; rd_addr = 5'd0; rd_data = 32'hFFFFFFFF;
    @(posedge clk); #1;
    rd_write_en = 0; rs1_addr = 5'd0; rs2_addr = 5'd0; #1;
    if (rs1_data !== 32'h0) $display("FALLO 4a: x0 por puerto 1 (rs1_data=%h)", rs1_data);
    if (rs2_data !== 32'h0) $display("FALLO 4b: x0 por puerto 2 (rs2_data=%h)", rs2_data);

    // 5. La escritura es sincrona: no se ve antes del flanco
    rd_write_en = 1; rd_addr = 5'd5; rd_data = 32'h0BADF00D; rs1_addr = 5'd5; #1;
    if (rs1_data !== 32'hDEADBEEF) $display("FALLO 5a: escritura asincrona (rs1_data=%h)", rs1_data);
    @(posedge clk); #1;
    if (rs1_data !== 32'h0BADF00D) $display("FALLO 5b: no se escribio (rs1_data=%h)", rs1_data);

    $display("Test regfile terminado");
    $finish;
  end
endmodule