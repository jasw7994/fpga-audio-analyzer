module note_display(
    input  logic clk,
    input  logic rst,
    input  logic [3:0] note_class,
    input  logic valid,
    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an
);

    always_comb begin
        an  = 4'b1110;
        dp  = 1'b1;
        seg = 7'b1111111;

        if(valid) begin
            case(note_class)
                4'd0:  begin seg=7'b1000110; dp=1'b1; end
                4'd1:  begin seg=7'b1000110; dp=1'b0; end
                4'd2:  begin seg=7'b0100001; dp=1'b1; end
                4'd3:  begin seg=7'b0100001; dp=1'b0; end
                4'd4:  begin seg=7'b0000110; dp=1'b1; end
                4'd5:  begin seg=7'b0001110; dp=1'b1; end
                4'd6:  begin seg=7'b0001110; dp=1'b0; end
                4'd7:  begin seg=7'b1000010; dp=1'b1; end
                4'd8:  begin seg=7'b1000010; dp=1'b0; end
                4'd9:  begin seg=7'b0001000; dp=1'b1; end
                4'd10: begin seg=7'b0001000; dp=1'b0; end
                4'd11: begin seg=7'b0000011; dp=1'b1; end
                default: begin seg=7'b1111111; dp=1'b1; end
            endcase
        end
    end
endmodule
