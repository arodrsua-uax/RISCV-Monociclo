// CSR de modo maquina y entrada/salida de excepciones. Trabaja en MEM: las
// lecturas son combinacionales y las escrituras se hacen en el flanco (con ce)
module csrfile (
  input  logic        clk, rst_n, ce,
  // Instruccion csrrw/s/c(i)
  input  logic        csr_en,      // instruccion CSR valida en MEM
  input  logic        csr_we,      // ademas escribe
  input  logic [11:0] csr_addr,
  input  logic [1:0]  csr_op,      // funct3[1:0]: 01 escribe, 10 pone bits, 11 borra bits
  input  logic [31:0] csr_wdata,   // rs1 o uimm
  output logic [31:0] csr_rdata,
  // Excepcion y mret
  input  logic        trap,
  input  logic [3:0]  cause,
  input  logic [31:0] tval,
  input  logic [31:0] epc,
  input  logic        mret,
  output logic [31:0] mtvec, mepc
);
  logic        mie, mpie;
  logic [29:0] mtvec_q, mepc_q;
  logic        mcause_int;           // bit 31 (aun no hay interrupciones)
  logic [3:0]  mcause_code;
  logic [31:0] mtval, mscratch;
  logic [31:0] wval;

  assign mtvec = {mtvec_q, 2'b00};   // solo modo directo
  assign mepc  = {mepc_q, 2'b00};    // sin extension C: alineado a 4

  always_comb
    case (csr_addr)
      12'h300: csr_rdata = {19'b0, 2'b11, 3'b0, mpie, 3'b0, mie, 3'b0};  // mstatus, MPP = M
      12'h301: csr_rdata = 32'h40000100;                                  // misa: RV32I
      12'h305: csr_rdata = mtvec;
      12'h340: csr_rdata = mscratch;
      12'h341: csr_rdata = mepc;
      12'h342: csr_rdata = {mcause_int, 27'b0, mcause_code};
      12'h343: csr_rdata = mtval;
      default: csr_rdata = 32'b0;   // mie, mip, mstatush e identificadores
    endcase

  always_comb
    case (csr_op)
      2'b10:   wval = csr_rdata | csr_wdata;
      2'b11:   wval = csr_rdata & ~csr_wdata;
      default: wval = csr_wdata;
    endcase

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      mie <= 1'b0;  mpie <= 1'b0;
      mtvec_q <= '0;  mepc_q <= '0;
      mcause_int <= 1'b0;  mcause_code <= '0;
      mtval <= '0;  mscratch <= '0;
    end else if (ce) begin
      if (trap) begin
        mepc_q      <= epc[31:2];
        mcause_int  <= 1'b0;
        mcause_code <= cause;
        mtval       <= tval;
        mpie        <= mie;
        mie         <= 1'b0;
      end else if (mret) begin
        mie  <= mpie;
        mpie <= 1'b1;
      end else if (csr_en && csr_we)
        case (csr_addr)
          12'h300: begin mie <= wval[3]; mpie <= wval[7]; end
          12'h305: mtvec_q  <= wval[31:2];
          12'h340: mscratch <= wval;
          12'h341: mepc_q   <= wval[31:2];
          12'h342: begin mcause_int <= wval[31]; mcause_code <= wval[3:0]; end
          12'h343: mtval    <= wval;
          default: ;   // misa, mie, mip...: se ignora
        endcase
    end
endmodule
