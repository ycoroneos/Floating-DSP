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
input wire CLK100MHZ,

//LEDS
output wire [7:0] led,

//switches
input wire [7:0] sw,

//audio codec
input wire ac_adc_sdata,
output wire ac_dac_sdata,
output wire ac_bclk,
output wire ac_lrclk,
output wire ac_mclk
    );
    
    wire reset=sw[0];
    assign led[0]=reset;
endmodule
