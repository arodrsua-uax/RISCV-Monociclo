module mux3 #( 
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic [WIDTH-1:0] d2,    
    input  logic [1:0] sel3,
    output logic [WIDTH-1:0] y3
);
    assign y3 = sel3[1] ? d2 : (sel3[0] ? d1 : d0);
endmodule   