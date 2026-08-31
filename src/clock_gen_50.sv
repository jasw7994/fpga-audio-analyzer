module clock_gen_50(
    input  logic clk100,
    input  logic reset,
    output logic clk50,
    output logic locked
);
    wire clkfb, clkfb_buf, clk50_unbuf;

    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKIN1_PERIOD(10.0),
        .DIVCLK_DIVIDE(1),
        .CLKFBOUT_MULT_F(10.0),
        .CLKOUT0_DIVIDE_F(20.0),
        .STARTUP_WAIT("FALSE")
    ) mmcm_inst (
        .CLKIN1(clk100),
        .CLKFBIN(clkfb_buf),
        .RST(reset),
        .PWRDWN(1'b0),
        .CLKFBOUT(clkfb),
        .CLKOUT0(clk50_unbuf),
        .LOCKED(locked),
        .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(),
        .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(),
        .CLKOUT4(), .CLKOUT5(), .CLKOUT6()
    );

    BUFG fb_buf(.I(clkfb), .O(clkfb_buf));
    BUFG out_buf(.I(clk50_unbuf), .O(clk50));
endmodule
