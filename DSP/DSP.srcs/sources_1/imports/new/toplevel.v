`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: busta rhymes
// 
// Create Date: 04/14/2017 11:37:23 AM
// Design Name: 
// Module Name: toplevel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module toplevel(
input wire sysclk,

//LEDS
output wire [7:0] led,

//switches
input wire [7:0] sw,

//audio codec
input wire AC_ADC_SDATA,
output wire AC_DAC_SDATA,
output wire AC_BCLK,
output wire AC_LRCLK,
output wire AC_MCLK,
output wire AC_SCL,
output wire AC_SDA,

//ports for debugging
//input wire [1:0]
inout wire [7:0] ja
    );
    
    wire reset=sw[0];
    assign led[0]=reset;
    
    //clocks we make
    //lrclk is generated from i2s transmitter
    wire mclk, lrclk, bclk, fsmclk, serialclk;
    clk_wiz_0 clkmon0(.reset(1'b0), .clk_in1(sysclk), .clk_out1(mclk)); //12.288mhz clock
    
    alt_divider #(.LOGLENGTH(4), .DIV_RATE(8)) bclkmon(.reset(1'b0), .inclk(mclk), .outclk(bclk));
    //alt_divider #(.LOGLENGTH(9), .DIV_RATE(512)) lrclkmon(.reset(1'b0), .inclk(mclk), .outclk(lrclk));
    alt_divider #(.LOGLENGTH(9), .DIV_RATE(123)) serialkclkmon(.reset(1'b0), .inclk(mclk), .outclk(serialclk));
    alt_divider #(.LOGLENGTH(18), .DIV_RATE(122880)) fsmclkmon(.reset(1'b0), .inclk(mclk), .outclk(fsmclk));
    
    //codec module
    wire output_data, input_data, codec_ready;
    //assign output_data=input_data;
    adau1761_controller codec(.reset(reset), .ac_mclk(AC_MCLK), .ac_bclk(AC_BCLK), .ac_lrclk(AC_LRCLK), .ac_sdto_dac(AC_DAC_SDATA), .ac_sdto_adc(AC_ADC_SDATA), .mclk(~mclk), .lrclk(lrclk), .bclk(~bclk), .fsmclk(fsmclk),
    .serialclk(serialclk), .sdto_from_codec(input_data), .sdto_to_codec(output_data), .ac_scl(AC_SCL), .ac_sda(AC_SDA), .ready(codec_ready));
    
    //data samples
    wire junk;
    wire [31:0] right_in;
    wire [31:0] left_in;
    wire [31:0] left_out = left_in[31:0];
    wire [31:0] right_out = right_in[31:0];
    //better_i2s_rx rx(.reset(~codec_ready), .bclk(~bclk), .lrclk(~lrclk), .sdto(input_data), .left_channel(left_in), .right_channel(right_in));
    //better_i2s_tx tx(.reset(~codec_ready), .bclk(~bclk), .lrclk(~lrclk), .sdto(output_data), .left_channel(left_out), .right_channel(right_out));
    wire [31:0] prescaler = 31'd32;
    i2s_rx #(.AUDIO_DW(32)) rx(.rst(~codec_ready), .sclk(~bclk), .lrclk(lrclk), .sdata(input_data), .left_chan(left_in), .right_chan(right_in));
    i2s_tx #(.AUDIO_DW(32)) tx(.rst(~codec_ready), .sclk(~bclk), .lrclk(lrclk), .sdata(output_data), .left_chan(left_out), .right_chan(right_out), .prescaler(prescaler));
    
    
    assign led[1]=codec_ready;
    assign led[2] = AC_LRCLK;
    assign led[3] = AC_SDA;
    assign led[4] = AC_SCL;
    assign led[5] = AC_MCLK;
    
    
    assign ja[0]=AC_SDA;
    assign ja[1]=AC_SCL;
    assign ja[2]=AC_MCLK;
    assign ja[3] = AC_LRCLK;
    assign ja[4] = AC_BCLK;
    assign ja[5] = fsmclk;
    assign ja[6] = serialclk;
    
endmodule
