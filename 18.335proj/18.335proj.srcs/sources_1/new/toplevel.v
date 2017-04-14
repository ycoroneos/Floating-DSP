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
output wire AC_SDA
    );
    wire CLK100MHZ=sysclk;
    
    wire reset=sw[0];
    assign led[0]=reset;
    
    //clocks we need
    wire mclk, lrclk, bclk, fsmclk;
    i2sclocks clkmon0(.reset(reset), .clk100mhz(CLK100MHZ), .mclk(mclk));
    divider #(.LOGLENGTH(4), .COUNTVAL(4)) bclkmon(.reset(reset), .inclk(mclk), .newclk(bclk)); //makes 3.072MHz clock from 12.288MHz clock
    divider #(.LOGLENGTH(9), .COUNTVAL(256)) lrclkmon(.reset(reset), .inclk(mclk), .newclk(lrclk)); //makes 48KHz clock from 12.288MHz clock
    divider #(.LOGLENGTH(15), .COUNTVAL(32768)) fsmclkmon(.reset(reset), .inclk(mclk), .newclk(fsmclk)); //makes 375Hz clock from 12.288MHz clock
    
    //codec module
    wire input_data, output_data;
    assign input_data=output_data;
    adau1761_controller codec(.reset(reset), .ac_mclk(AC_MCLK), .ac_bclk(AC_BCLK), .ac_lrclk(AC_LRCLK), .ac_sdto_dac(AC_DAC_SDATA), .ac_sdto_adc(AC_ADC_SDATA), .mclk(mclk), .lrclk(lrclk), .bclk(bclk), .fsmclk(fsmclk),
    .sdto_in(input_data), .sdto_out(output_data), .ac_scl(AC_SCL), .ac_sda(AC_SDA));
endmodule
