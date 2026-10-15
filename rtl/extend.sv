module extend (
    input  logic [31:0] instr,
    output logic [31:0] immext
);

  always_comb begin
    case (instr[6:0])
      7'b0010011, 7'b0000011, 7'b1100111:
        immext = {{20{instr[31]}}, instr[31:20]};                                           // I
      7'b0100011:
        immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};                              // S
      7'b1100011:
        immext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};   // B
      7'b0110111, 7'b0010111:
        immext = {instr[31:12], 12'b0};                                                     // U
      7'b1101111:
        immext = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J
      default:
        immext = '0;
    endcase
  end
endmodule