module mux2 #( 
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic sel2,
    output logic [WIDTH-1:0] y2
);
    assign y2 = sel2 ? d1 : d0;
endmodule   