module controldec (
  input  logic [31:0] instr,
  output logic        RegWrite, MemWrite, Branch, Jump, Jalr,
  output logic [1:0]  ResultSrc,
  output logic        ALUSrc, ASrc,
  output logic [3:0]  ALUControl
);

  always_comb begin
    // Valores por defecto
    RegWrite   = 0;
    MemWrite   = 0;
    Branch     = 0;
    Jump       = 0;
    Jalr       = 0;
    ResultSrc  = 2'b00;
    ALUSrc     = 0;
    ASrc       = 0;       // 0: primer operando de la ALU es rs1, 1: es el PC
    ALUControl = 4'b0000;

    case (instr[6:0])
      // R-type e I-type aritmética: misma decodificación de funct3
      7'b0110011, 7'b0010011: begin
        RegWrite   = 1;
        ResultSrc  = 2'b00;   // ALUResult
        ALUSrc     = ~instr[5]; // 0 en tipo R (registro), 1 en tipo I (inmediato)
        case (instr[14:12])
          3'b000: ALUControl = (instr[5] & instr[30]) ? 4'b0001 : 4'b0000; // sub o add/addi
          3'b001: ALUControl = 4'b1001;                                     // sll, slli
          3'b010: ALUControl = 4'b0101;                                     // slt, slti
          3'b011: ALUControl = 4'b1100;                                     // sltu, sltiu
          3'b100: ALUControl = 4'b1000;                                     // xor, xori
          3'b101: ALUControl = instr[30] ? 4'b1011 : 4'b1010;               // sra/srai o srl/srli
          3'b110: ALUControl = 4'b0011;                                     // or, ori
          3'b111: ALUControl = 4'b0010;                                     // and, andi
        endcase
      end

      // I-type (load)
      7'b0000011: begin
        RegWrite   = 1;
        ResultSrc  = 2'b01;   // ReadData
        ALUSrc     = 1;       // segundo operando de la ALU viene de la extensión inmediata
        ALUControl = 4'b0000; // add (para calcular la dirección)
      end

      // S-type (store)
      7'b0100011: begin
        MemWrite   = 1;
        ALUSrc     = 1;       // segundo operando de la ALU viene de la extensión inmediata
        ALUControl = 4'b0000; // add (para calcular la dirección)
      end

      // B-type (branch): la ALU compara rs1 y rs2; el controller decide
      // con Zero y funct3 si se salta
      7'b1100011: begin
        Branch     = 1;
        ALUSrc     = 0;       // segundo operando de la ALU viene del registro
        case (instr[14:13])
          2'b00:   ALUControl = 4'b0001; // beq, bne: sub (Zero = iguales)
          2'b10:   ALUControl = 4'b0101; // blt, bge: slt (Zero = no menor con signo)
          2'b11:   ALUControl = 4'b1100; // bltu, bgeu: sltu (Zero = no menor sin signo)
          default: ALUControl = 4'b0001; // funct3 = 01x no existe
        endcase
      end

      // U-type (lui): rd = inmediato U, sin pasar por la ALU
      7'b0110111: begin
        RegWrite   = 1;
        ResultSrc  = 2'b11;   // ImmExt
      end

      // U-type (auipc): rd = PC + inmediato U, calculado en la ALU
      7'b0010111: begin
        RegWrite   = 1;
        ResultSrc  = 2'b00;   // ALUResult
        ASrc       = 1;       // primer operando de la ALU es el PC
        ALUSrc     = 1;       // segundo operando de la ALU es la extensión inmediata
        ALUControl = 4'b0000; // add
      end

      // J-type (jal)
      7'b1101111: begin
        RegWrite   = 1;
        ResultSrc  = 2'b10;   // PC+4
        Jump       = 1;
      end

      // I-type (jalr): rd = PC+4, PC = (rs1 + inmediato) & ~1, calculado en la ALU
      7'b1100111: begin
        RegWrite   = 1;
        ResultSrc  = 2'b10;   // PC+4
        ALUSrc     = 1;       // segundo operando de la ALU es la extensión inmediata
        ALUControl = 4'b0000; // add
        Jalr       = 1;
      end
    endcase
  end
endmodule
