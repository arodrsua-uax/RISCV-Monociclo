// Decodificacion en ID de lo que controldec no mira: instrucciones ilegales
// (RV32I estricto), ecall, ebreak, mret y acceso a CSR (Zicsr, solo modo M)
module sysdec (
  input  logic [31:0] instr,
  output logic        Illegal,   // codificacion no valida en RV32I + Zicsr
  output logic        Ecall, Ebreak, Mret,
  output logic        Csr,       // csrrw/s/c(i) a un CSR existente
  output logic        CsrWrite   // el CSR se escribe (csrrs/c con rs1 = 0 no)
);
  logic [6:0]  op, f7;
  logic [2:0]  f3;
  logic [11:0] csra;
  logic        csrok, csrro, wr;

  assign op   = instr[6:0];
  assign f3   = instr[14:12];
  assign f7   = instr[31:25];
  assign csra = instr[31:20];

  assign Ecall  = (instr == 32'h00000073);
  assign Ebreak = (instr == 32'h00100073);
  assign Mret   = (instr == 32'h30200073);

  // CSR existentes; los F1x son de solo lectura
  always_comb
    case (csra)
      12'h300, 12'h301, 12'h304, 12'h305, 12'h310,             // mstatus misa mie mtvec mstatush
      12'h340, 12'h341, 12'h342, 12'h343, 12'h344,             // mscratch mepc mcause mtval mip
      12'hF11, 12'hF12, 12'hF13, 12'hF14, 12'hF15: csrok = 1'b1;
      default:                                     csrok = 1'b0;
    endcase
  assign csrro = (csra[11:10] == 2'b11);
  assign wr    = (f3[1:0] == 2'b01) || (instr[19:15] != 5'd0);

  assign Csr      = (op == 7'b1110011) && (f3[1:0] != 2'b00) && csrok && !(csrro && wr);
  assign CsrWrite = wr;

  always_comb begin
    Illegal = 1'b0;
    if (instr[1:0] != 2'b11) Illegal = 1'b1;              // comprimidas: no hay extension C
    else
      case (op)
        7'b0110111, 7'b0010111, 7'b1101111: ;               // lui, auipc, jal
        7'b1100111: Illegal = (f3 != 3'b000);               // jalr
        7'b1100011: Illegal = (f3[2:1] == 2'b01);           // branch: 010 y 011 no existen
        7'b0000011: Illegal = (f3 == 3'b011) || (f3[2:1] == 2'b11);   // lb lh lw lbu lhu
        7'b0100011: Illegal = (f3[2] || f3 == 3'b011);      // sb sh sw
        7'b0010011:                                         // aritmetica con inmediato
          if (f3 == 3'b001)      Illegal = (f7 != 7'b0000000);
          else if (f3 == 3'b101) Illegal = (f7 != 7'b0000000) && (f7 != 7'b0100000);
        7'b0110011:                                         // aritmetica con registros
          Illegal = !((f7 == 7'b0000000) ||
                      (f7 == 7'b0100000 && (f3 == 3'b000 || f3 == 3'b101)));
        7'b0001111: Illegal = (f3[2:1] != 2'b00);           // fence y fence.i
        7'b1110011:                                         // system
          if (f3 == 3'b000)
            Illegal = !(Ecall || Ebreak || Mret || instr == 32'h10500073);   // wfi = NOP
          else
            Illegal = !Csr;
        default:    Illegal = 1'b1;
      endcase
  end
endmodule
