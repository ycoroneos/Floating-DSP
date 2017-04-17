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
    wire mclk, lrclk, bclk, fsmclk, serialclk;
    clk_wiz_0 clkmon0(.reset(1'b0), .clk_in1(sysclk), .clk_out1(mclk)); //48mhz clock
    
    alt_divider #(.LOGLENGTH(4), .DIV_RATE(4)) bclkmon(.reset(1'b0), .inclk(mclk), .outclk(bclk));
    alt_divider #(.LOGLENGTH(9), .DIV_RATE(256)) lrclkmon(.reset(1'b0), .inclk(mclk), .outclk(lrclk));
    alt_divider #(.LOGLENGTH(9), .DIV_RATE(123)) serialkclkmon(.reset(1'b0), .inclk(mclk), .outclk(serialclk));
    alt_divider #(.LOGLENGTH(18), .DIV_RATE(122880)) fsmclkmon(.reset(1'b0), .inclk(mclk), .outclk(fsmclk));
    
    //codec module
    assign output_data=input_data;
    adau1761_controller codec(.reset(reset), .ac_mclk(AC_MCLK), .ac_bclk(AC_BCLK), .ac_lrclk(AC_LRCLK), .ac_sdto_dac(AC_DAC_SDATA), .ac_sdto_adc(AC_ADC_SDATA), .mclk(~mclk), .lrclk(~lrclk), .bclk(~bclk), .fsmclk(fsmclk),
    .serialclk(serialclk), .sdto_from_codec(input_data), .sdto_to_codec(output_data), .ac_scl(AC_SCL), .ac_sda(AC_SDA), .ready(led[1]));
    
    
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
