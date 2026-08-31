module fir_decimate4 #(
    parameter int TAPS=191
)(
    input logic clk,input logic rst,
    input logic signed [23:0] sample_in,
    input logic sample_valid,
    output logic signed [23:0] sample_out,
    output logic sample_out_valid,
    output logic busy
);
    logic signed [23:0] delay[0:TAPS-1];
    logic signed [15:0] coeff[0:TAPS-1];
    initial $readmemh("fir191.mem",coeff);

    logic [7:0] tap_index;
    logic [1:0] decim_phase;
    logic [7:0] warmup_count;
    logic signed [39:0] product;
    logic signed [47:0] accumulator,product_ext,final_sum,shifted_result;
    integer i;

    assign product=delay[tap_index]*coeff[tap_index];
    assign product_ext={{8{product[39]}},product};
    assign final_sum=accumulator+product_ext;
    assign shifted_result=final_sum>>>15;

    function automatic logic signed[23:0] sat24(input logic signed[47:0] v);
        if(v>48'sd8388607) sat24=24'sh7FFFFF;
        else if(v<-48'sd8388608) sat24=-24'sd8388608;
        else sat24=v[23:0];
    endfunction

    always_ff @(posedge clk) begin
        if(rst) begin
            for(i=0;i<TAPS;i=i+1) delay[i]<=0;
            tap_index<=0;decim_phase<=0;warmup_count<=0;accumulator<=0;sample_out<=0;sample_out_valid<=0;busy<=0;
        end else begin
            sample_out_valid<=0;
            if(sample_valid) begin
                for(i=TAPS-1;i>0;i=i-1) delay[i]<=delay[i-1];
                delay[0]<=sample_in;
                if(warmup_count<TAPS) warmup_count<=warmup_count+1'b1;
                if(decim_phase==3) begin
                    decim_phase<=0;
                    if((warmup_count>=TAPS-1)&&!busy) begin tap_index<=0;accumulator<=0;busy<=1;end
                end else decim_phase<=decim_phase+1'b1;
            end

            if(busy) begin
                if(tap_index==TAPS-1) begin
                    sample_out<=sat24(shifted_result);sample_out_valid<=1;busy<=0;tap_index<=0;accumulator<=0;
                end else begin
                    accumulator<=accumulator+product_ext;tap_index<=tap_index+1'b1;
                end
            end
        end
    end
endmodule
