module dft_coefficient_2048(
    input logic [10:0] row,
    input logic [10:0] col,
    output logic signed [8:0] realPart,
    output logic signed [8:0] imagPart
);
    logic [21:0] row_col_product;
    logic [10:0] phase_index;
    logic signed [8:0] cos_rom[0:2047];
    logic signed [8:0] sin_rom[0:2047];

    initial begin
        $readmemh("cos2048.mem",cos_rom);
        $readmemh("sin2048.mem",sin_rom);
    end

    assign row_col_product=row*col;
    assign phase_index=row_col_product[10:0];
    assign realPart=cos_rom[phase_index];
    assign imagPart=sin_rom[phase_index];
endmodule
