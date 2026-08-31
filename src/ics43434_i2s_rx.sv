module ics43434_i2s_rx #(
    parameter int BCLK_HALF_DIV=8
)(
    input logic clk,input logic rst,input logic mic_data,
    output logic mic_bclk,output logic mic_lrclk,
    output logic signed [23:0] sample,
    output logic sample_valid
);
    localparam int DIV_WIDTH=$clog2(BCLK_HALF_DIV);
    logic [DIV_WIDTH-1:0] div_count;
    logic [5:0] bit_in_slot;
    logic toggle_lr_pending,synced;
    logic [23:0] shift_reg;

    always_ff @(posedge clk) begin
        if(rst) begin
            div_count<='0;mic_bclk<=0;mic_lrclk<=0;bit_in_slot<=0;toggle_lr_pending<=0;synced<=0;shift_reg<=0;sample<=0;sample_valid<=0;
        end else begin
            sample_valid<=0;
            if(div_count==BCLK_HALF_DIV-1) begin
                div_count<=0;
                if(!mic_bclk) begin
                    mic_bclk<=1;
                    if((mic_lrclk==0)&&(bit_in_slot>=1)&&(bit_in_slot<=24)) begin
                        shift_reg<={shift_reg[22:0],mic_data};
                        if((bit_in_slot==24)&&synced) begin
                            sample<=$signed({shift_reg[22:0],mic_data});
                            sample_valid<=1;
                        end
                    end
                    if(bit_in_slot==31) begin bit_in_slot<=0;toggle_lr_pending<=1;end
                    else bit_in_slot<=bit_in_slot+1'b1;
                end else begin
                    mic_bclk<=0;
                    if(toggle_lr_pending) begin
                        if(mic_lrclk==1) synced<=1;
                        mic_lrclk<=~mic_lrclk;toggle_lr_pending<=0;
                    end
                end
            end else div_count<=div_count+1'b1;
        end
    end
endmodule
