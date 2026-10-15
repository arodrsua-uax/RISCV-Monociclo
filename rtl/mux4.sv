module mux4 #(
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic [WIDTH-1:0] d2,
    input  logic [WIDTH-1:0] d3,
    input  logic [1:0] sel4,
    output logic [WIDTH-1:0] y4
);
    assign y4 = sel4[1] ? (sel4[0] ? d3 : d2) : (sel4[0] ? d1 : d0);
endmodule
