module regfile #(
    // RESET = 1: el reset pone los 32 registros a 0 (biestables).
    // RESET = 0: sin reset, Vivado lo implementa en LUTRAM (mucha menos área);
    //            los registros empiezan a 0 por el initial (simulación y bitstream)
    parameter RESET = 1
)(
    input logic clk,
    input logic rst_n,
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] rd_addr,
    input logic [31:0] rd_data,
    input logic rd_write_en,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    // Banco de registros de 32 registros de 32 bits
    logic [31:0] regfile_array [31:0];

    // Operación de lectura: si la dirección es 0, devolver 0; de lo contrario, 
    // devolver el valor del registro correspondiente
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regfile_array[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regfile_array[rs2_addr];

    // Operación de escritura: en el flanco positivo del reloj, si rd_write_en es alto y
    // la dirección no es 0, escribir rd_data en el registro correspondiente
    generate
        if (RESET) begin : con_reset
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    // Inicializar todos los registros a 0 en el reset
                    for (int i = 0; i < 32; i++) begin
                        regfile_array[i] <= 32'd0;
                    end
                end else if (rd_write_en && rd_addr != 5'd0) begin
                    // Escribir datos en el registro especificado si el habilitador de escritura
                    // es alto y la dirección no es cero
                    regfile_array[rd_addr] <= rd_data;
                end
            end
        end else begin : sin_reset
            initial for (int i = 0; i < 32; i++) regfile_array[i] = 32'd0;

            always_ff @(posedge clk)
                if (rd_write_en && rd_addr != 5'd0)
                    regfile_array[rd_addr] <= rd_data;
        end
    endgenerate
endmodule
