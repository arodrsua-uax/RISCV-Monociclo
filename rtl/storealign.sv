// storealign.sv: prepara la escritura en dmem de sb, sh y sw.
// Copia el byte o la media palabra de rs2 en la posición que indica addr[1:0]
// y activa solo los bytes que hay que escribir.
module storealign (
  input  logic [2:0]  funct3,      // 000: sb, 001: sh, 010: sw
  input  logic [1:0]  addr,        // dos bits bajos de la dirección
  input  logic [31:0] rs2_data,
  output logic [31:0] write_data,
  output logic [3:0]  byte_en
);

  always_comb begin
    case (funct3[1:0])
      2'b00: begin   // sb
        write_data = {4{rs2_data[7:0]}};
        byte_en    = 4'b0001 << addr;
      end
      2'b01: begin   // sh (addr[0] se ignora: accesos no alineados no soportados)
        write_data = {2{rs2_data[15:0]}};
        byte_en    = addr[1] ? 4'b1100 : 4'b0011;
      end
      default: begin // sw
        write_data = rs2_data;
        byte_en    = 4'b1111;
      end
    endcase
  end
endmodule
