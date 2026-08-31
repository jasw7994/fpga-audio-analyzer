module bin_to_note(
    input  logic [10:0] bin,
    output logic [3:0] note_class,
    output logic valid
);

    logic [3:0] note_rom[0:1023];

    initial $readmemh("note_class_1024.mem",note_rom);

    always_comb begin
        if(bin<=11'd1023) begin
            note_class=note_rom[bin];
            valid=(note_rom[bin]!=4'hF);
        end else begin
            note_class=4'hF;
            valid=1'b0;
        end
    end
endmodule
