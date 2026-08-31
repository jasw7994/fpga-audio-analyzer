module audio_note_top(
    input  logic CLK100MHZ,
    input  logic btnC,

    output logic mic_bclk,
    output logic mic_lrclk,
    input  logic mic_data,

    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an
);
    localparam int ACC_WIDTH=45;

    logic clk50,locked,system_reset;
    clock_gen_50 clock_gen_inst(.clk100(CLK100MHZ),.reset(btnC),.clk50(clk50),.locked(locked));
    assign system_reset=btnC|~locked;

    logic signed [23:0] raw_sample;
    logic raw_sample_valid;

    ics43434_i2s_rx #(.BCLK_HALF_DIV(8)) mic_rx(
        .clk(clk50),.rst(system_reset),.mic_data(mic_data),
        .mic_bclk(mic_bclk),.mic_lrclk(mic_lrclk),
        .sample(raw_sample),.sample_valid(raw_sample_valid)
    );

    logic signed [23:0] dec_sample;
    logic dec_sample_valid,fir_busy;

    fir_decimate4 fir(
        .clk(clk50),.rst(system_reset),
        .sample_in(raw_sample),.sample_valid(raw_sample_valid),
        .sample_out(dec_sample),.sample_out_valid(dec_sample_valid),
        .busy(fir_busy)
    );

    typedef enum logic[1:0]{CAPTURE,START_DFT,WAIT_DFT} state_t;
    state_t state;

    logic [10:0] capture_addr;
    logic dft_start;
    logic dft_sample_we;
    assign dft_sample_we=(state==CAPTURE)&&dec_sample_valid;

    logic [10:0] dft_bin;
    logic signed [ACC_WIDTH-1:0] dft_real,dft_imag;
    logic dft_output_valid,dft_busy,dft_done;

    dft2048 #(.DATA_WIDTH(24),.COEF_WIDTH(9),.ACC_WIDTH(ACC_WIDTH)) transform(
        .clk(clk50),.rst(system_reset),.start(dft_start),
        .sample_we(dft_sample_we),.sample_write_addr(capture_addr),.sample_in(dec_sample),
        .output_bin(dft_bin),.real_output(dft_real),.imag_output(dft_imag),
        .output_valid(dft_output_valid),.busy(dft_busy),.done(dft_done)
    );

    logic [ACC_WIDTH-1:0] abs_real,abs_imag;
    logic [ACC_WIDTH:0] approx_mag;
    always_comb begin
        abs_real=dft_real[ACC_WIDTH-1]?$unsigned(-dft_real):$unsigned(dft_real);
        abs_imag=dft_imag[ACC_WIDTH-1]?$unsigned(-dft_imag):$unsigned(dft_imag);
        approx_mag={1'b0,abs_real}+{1'b0,abs_imag};
    end

    logic [ACC_WIDTH:0] peak_mag;
    logic [10:0] peak_bin,last_peak_bin;

    always_ff @(posedge clk50) begin
        if(system_reset) begin
            state<=CAPTURE;capture_addr<=0;dft_start<=0;
            peak_mag<=0;peak_bin<=0;last_peak_bin<=0;
        end else begin
            dft_start<=0;
            case(state)
                CAPTURE: if(dec_sample_valid) begin
                    if(capture_addr==2047) begin capture_addr<=0;state<=START_DFT;end
                    else capture_addr<=capture_addr+1'b1;
                end

                START_DFT: begin peak_mag<=0;peak_bin<=0;dft_start<=1;state<=WAIT_DFT;end

                WAIT_DFT: begin
                    if(dft_output_valid&&(dft_bin>=1)&&(dft_bin<=1023)&&(approx_mag>peak_mag)) begin
                        peak_mag<=approx_mag;
                        peak_bin<=dft_bin;
                    end
                    if(dft_done) begin last_peak_bin<=peak_bin;state<=CAPTURE;end
                end
            endcase
        end
    end

    logic [3:0] detected_note;
    logic detected_note_valid;

    bin_to_note note_lookup(
        .bin(last_peak_bin),
        .note_class(detected_note),
        .valid(detected_note_valid)
    );

    note_display display(
        .clk(clk50),.rst(system_reset),
        .note_class(detected_note),.valid(detected_note_valid),
        .seg(seg),.dp(dp),.an(an)
    );
endmodule
