// loadext.sv: extrae de la palabra leída de dmem el dato de lb, lh, lw, lbu y lhu.
// Elige el byte o la media palabra según addr[1:0] y lo extiende con signo o con ceros.
module loadext (
  input  logic [2:0]  funct3,      // 000: lb, 001: lh, 010: lw, 100: lbu, 101: lhu
  input  logic [1:0]  addr,        // dos bits bajos de la dirección
  input  logic [31:0] mem_data,
  output logic [31:0] read_data
);

  logic [7:0]  byte_sel;
  logic [15:0] half_sel;

  assign byte_sel = mem_data[8*addr +: 8];
  assign half_sel = addr[1] ? mem_data[31:16] : mem_data[15:0];   // addr[0] se ignora

  always_comb begin
    case (funct3)
      3'b000:  read_data = {{24{byte_sel[7]}},  byte_sel};   // lb
      3'b001:  read_data = {{16{half_sel[15]}}, half_sel};   // lh
      3'b100:  read_data = {24'b0, byte_sel};                // lbu
      3'b101:  read_data = {16'b0, half_sel};                // lhu
      default: read_data = mem_data;                         // lw
    endcase
  end
endmodule
