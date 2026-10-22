module floprec #(
  parameter WIDTH = 32
)(
  input  logic             clk, rst_n, ce, en, clr,
  input  logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) q <= '0;
    else if (ce) begin
      if (clr)     q <= '0;
      else if (en) q <= d;
    end
endmodule