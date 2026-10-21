module forwardunit (
  input  logic [4:0] Rs1E, Rs2E, RdM, RdW,
  input  logic       RegWriteM, RegWriteW,
  output logic [1:0] ForwardAE, ForwardBE
);

  always_comb begin
    // Operando A
    if      (RegWriteM && (RdM != 0) && (RdM == Rs1E)) ForwardAE = 2'b10;
    else if (RegWriteW && (RdW != 0) && (RdW == Rs1E)) ForwardAE = 2'b01;
    else                                               ForwardAE = 2'b00;

    // Operando B
    if      (RegWriteM && (RdM != 0) && (RdM == Rs2E)) ForwardBE = 2'b10;
    else if (RegWriteW && (RdW != 0) && (RdW == Rs2E)) ForwardBE = 2'b01;
    else                                               ForwardBE = 2'b00;
  end
endmodule