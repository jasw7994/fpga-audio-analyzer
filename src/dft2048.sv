module dft2048 #(
    parameter int DATA_WIDTH=24,
    parameter int COEF_WIDTH=9,
    parameter int ACC_WIDTH=45
)(
    input logic clk,input logic rst,input logic start,
    input logic sample_we,
    input logic [10:0] sample_write_addr,
    input logic signed [DATA_WIDTH-1:0] sample_in,
    output logic [10:0] output_bin,
    output logic signed [ACC_WIDTH-1:0] real_output,
    output logic signed [ACC_WIDTH-1:0] imag_output,
    output logic output_valid,
    output logic busy,
    output logic done
);
    logic signed [DATA_WIDTH-1:0] sample_mem[0:2047];
    always_ff @(posedge clk) if(sample_we) sample_mem[sample_write_addr]<=sample_in;

    logic [10:0] row,col;
    logic signed [COEF_WIDTH-1:0] rc,ic;
    dft_coefficient_2048 coeffs(.row(row),.col(col),.realPart(rc),.imagPart(ic));

    logic mac_step,mac_load;
    logic signed [ACC_WIDTH-1:0] racc,iacc;

    mac #(.DATA_WIDTH(DATA_WIDTH),.COEF_WIDTH(COEF_WIDTH),.ACC_WIDTH(ACC_WIDTH))
    rm(.clk(clk),.rst(rst),.step(mac_step),.load(mac_load),.a(sample_mem[col]),.b(rc),.accumulator(racc));

    mac #(.DATA_WIDTH(DATA_WIDTH),.COEF_WIDTH(COEF_WIDTH),.ACC_WIDTH(ACC_WIDTH))
    im(.clk(clk),.rst(rst),.step(mac_step),.load(mac_load),.a(sample_mem[col]),.b(ic),.accumulator(iacc));

    typedef enum logic[1:0]{IDLE,CALCULATE,SAVE,FINISHED} state_t;
    state_t state;

    always_comb begin
        mac_step=(state==CALCULATE);
        mac_load=(state==CALCULATE)&&(col==0);
        busy=(state==CALCULATE)||(state==SAVE);
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            state<=IDLE;row<=0;col<=0;output_bin<=0;real_output<=0;imag_output<=0;output_valid<=0;done<=0;
        end else begin
            output_valid<=0;done<=0;
            case(state)
                IDLE: if(start) begin row<=0;col<=0;state<=CALCULATE;end
                CALCULATE: if(col==2047) state<=SAVE; else col<=col+1'b1;
                SAVE: begin
                    output_bin<=row;real_output<=racc;imag_output<=iacc;output_valid<=1;col<=0;
                    if(row==2047) state<=FINISHED;
                    else begin row<=row+1'b1;state<=CALCULATE;end
                end
                FINISHED: begin done<=1;state<=IDLE;end
            endcase
        end
    end
endmodule
