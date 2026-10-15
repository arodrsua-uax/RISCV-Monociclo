// flopr.sv implementa un registro con reset asincrono activo en bajo (rst_n) y flanco de subida con flipflops de tipo D.
// El registro tiene un ancho parametrizable mediante el parámetro WIDTH.
module flopr #(
  parameter WIDTH = 32
)
(
  input logic clk,
  input logic rst_n,
  input logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= '0;
    end else begin
      q <= d;
    end
    end
endmodule