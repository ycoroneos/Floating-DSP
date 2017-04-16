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
input wire AC_BCLK,
input wire AC_LRCLK,
output wire AC_MCLK,
output wire AC_SCL,
output wire AC_SDA,

//ports for debugging
//input wire [1:0]
inout wire [7:0] ja
    );
    //wire CLK100MHZ;
    //assign CLK100MHz=sysclk;
    
    wire reset=sw[0];
    assign led[0]=reset;
    
    //clocks we make
    wire mclk, fsmclk, serialclk;
    
    //clocks we receive from codec
    wire lrclk, bclk;
    clk_wiz_0 clkmon0(.reset(1'b0), .clk_in1(sysclk), .clk_out1(mclk)); //24mhz clock
   // divider #(.LOGLENGTH(4), .COUNTVAL(4/2)) bclkmon(.reset(1'b0), .inclk(mclk), .newclk(bclk)); //makes 3.072MHz clock from 12.288MHz clock
   // divider #(.LOGLENGTH(9), .COUNTVAL(256/2)) lrclkmon(.reset(1'b0), .inclk(mclk), .newclk(lrclk)); //makes 48KHz clock from 12.288MHz clock
    divider #(.LOGLENGTH(24), .COUNTVAL(2400000/2)) fsmclkmon(.reset(1'b0), .inclk(mclk), .newclk(fsmclk)); //makes 100Hz clock from 100MHz clock
    divider #(.LOGLENGTH(14), .COUNTVAL(2500/2)) serialclkmon(.reset(1'b0), .inclk(mclk), .newclk(serialclk)); //makes 100Hz clock from 100MHz clock
    
    //codec module
    //wire junk1, junk2;
    wire sda, scl;
    assign AC_SCL = scl;
    assign AC_SDA= sda;
    wire input_data, output_data;
    assign output_data=input_data;
    //assign AC_MCLK=mclk;
    adau1761_controller codec(.reset(reset), .ac_mclk(AC_MCLK), .ac_bclk(AC_BCLK), .ac_lrclk(AC_LRCLK), .ac_sdto_dac(AC_DAC_SDATA), .ac_sdto_adc(AC_ADC_SDATA), .mclk(mclk), .lrclk(lrclk), .bclk(bclk), .fsmclk(fsmclk),
    .serialclk(serialclk), .sdto_from_codec(input_data), .sdto_to_codec(output_data), .ac_scl(scl), .ac_sda(sda), .ready(led[1]));
    
    //assign sda=ja[1];
    //assign scl=ja[0];
    //debugging stuff
    //assign AC_SCL=scl;
    //assign AC_SDA=sda;
    assign led[2] = AC_LRCLK;
    assign led[3] = AC_SDA;
    assign led[4] = AC_SCL;
    assign led[5] = AC_MCLK;
    
    assign AC_SDA=ja[0];
    assign AC_SCL=ja[1];
    
   //assign ja[0]=sda;
    //assign ja[1]=scl;
    //assign ja[0]=fsmclk;
    //assign ja[1]=lrclk;
    //assign ja[2]=bclk;
    //assign ja[3]=mclk;
    //assign ja[4]=AC_SCL;
    //assign ja[5]=AC_SDA;
endmodule
