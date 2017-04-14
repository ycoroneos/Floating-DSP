`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2017 11:45:49 AM
// Design Name: 
// Module Name: adau1761_controller
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


module adau1761_controller(

//reset
input wire reset,

//input/output to device
output wire ac_mclk,
output wire ac_lrclk,
output wire ac_bclk,
output wire ac_sdto_dac,
input wire ac_sdto_in,
output wire ac_scl,
inout wire ac_sda,

//input from clockgen
input wire mclk, //i2s mclk
input wire lrclk, //i2slrclk
input wire bclk, //i2sbclk
input wire fsmclk, //state machine clock

//input/output from DSP modules
input wire sdto_in,
output wire sdto_out
    );
    
    //i2c controller
    reg i2cstart=0;
    reg [34:0] controldata;
    adau1761i2c configbus(.reset(reset), .serialclk(clk9600), .start(i2cstart), .data(controldata), .scl(ac_sdl), .sda(ac_sda));
    
    //fsm stuff
    reg [4:0] curstate=0;
    always @(posedge FSMCLK)
    begin
    end
endmodule
