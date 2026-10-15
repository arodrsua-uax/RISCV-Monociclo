// =====================================================================
// alu.sv
// Contiene la ALU y dos módulos auxiliares (desplazador y comparador)
// en el mismo archivo. Los módulos auxiliares van ANTES de la ALU para
// que el compilador ya los conozca cuando se instancian.
// =====================================================================

// ---------------------------------------------------------------------
// Desplazador: SLL, SRL, SRA (y sus variantes inmediatas SLLI/SRLI/SRAI,
// que reutilizan los mismos códigos de control porque el inmediato
// llega por la entrada b).
// ---------------------------------------------------------------------
module alu_shifter (
    input  logic [31:0] a,
    input  logic [4:0]  shamt,
    input  logic [3:0]  alucontrol,
    output logic [31:0] y
);

  always_comb begin
    case (alucontrol)
      4'b1001: y = a << shamt;            // SLL
      4'b1010: y = a >> shamt;            // SRL
      4'b1011: y = $signed(a) >>> shamt;  // SRA
      default: y = 32'h0;
    endcase
  end

endmodule

// ---------------------------------------------------------------------
// Comparador: SLT, SLTU
// ---------------------------------------------------------------------
module alu_cmp (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alucontrol,
    output logic [31:0] y
);

  always_comb begin
    case (alucontrol)
      4'b0101: y = {31'b0, $signed(a) < $signed(b)};  // SLT
      4'b1100: y = {31'b0, a < b};                    // SLTU
      default: y = 32'h0;
    endcase
  end

endmodule

// ---------------------------------------------------------------------
// ALU: el case solo selecciona el resultado
// ---------------------------------------------------------------------
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alucontrol,
    output logic [31:0] result,
    output logic        zero
);

  logic [31:0] shift_res, cmp_res;

  alu_shifter u_shifter (
      .a         (a),
      .shamt     (b[4:0]),
      .alucontrol(alucontrol),
      .y         (shift_res)   // salida del módulo de desplazamiento
  );

  alu_cmp u_cmp (
      .a         (a),
      .b         (b),
      .alucontrol(alucontrol),
      .y         (cmp_res)    // salida del módulo de comparación
  );

  always_comb begin
    case (alucontrol)

      4'b0000: result = a + b;            // ADD
      4'b0001: result = a - b;            // SUB
      4'b0010: result = a & b;            // AND
      4'b0011: result = a | b;            // OR
      4'b1000: result = a ^ b;            // XOR

      4'b0101,                            // SLT
      4'b1100: result = cmp_res;          // SLTU Salida del módulo de comparación

      4'b1001,                            // SLL
      4'b1010,                            // SRL
      4'b1011: result = shift_res;        // SRA  Salida del módulo de desplazamiento

      default: result = 32'hDEADBEEF;     // valor por defecto para depuración
    endcase
  end

  assign zero = (result == 32'h0);

endmodule