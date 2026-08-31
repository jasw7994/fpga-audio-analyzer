module mac #(
    parameter int DATA_WIDTH=24,
    parameter int COEF_WIDTH=9,
    parameter int ACC_WIDTH=45
)(
    input logic clk, input logic rst,
    input logic step, input logic load,
    input logic signed [DATA_WIDTH-1:0] a,
    input logic signed [COEF_WIDTH-1:0] b,
    output logic signed [ACC_WIDTH-1:0] accumulator
);
    localparam int PRODUCT_WIDTH=DATA_WIDTH+COEF_WIDTH;
    logic signed [PRODUCT_WIDTH-1:0] product;
    logic signed [ACC_WIDTH-1:0] extended_product;

    assign product=a*b;
    assign extended_product={{(ACC_WIDTH-PRODUCT_WIDTH){product[PRODUCT_WIDTH-1]}},product};

    always_ff @(posedge clk) begin
        if(rst) accumulator<='0;
        else if(step) begin
            if(load) accumulator<=extended_product;
            else accumulator<=accumulator+extended_product;
        end
    end
endmodule
