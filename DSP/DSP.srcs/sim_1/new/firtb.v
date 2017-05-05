`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2017 08:45:38 PM
// Design Name: 
// Module Name: firtb
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


module firtb(

    );
    //memory for the filter coefficients
    localparam NTAPS=6;
    localparam WIDTH=32;
    wire [(NTAPS*(WIDTH))-1 : 0] coeffs;
    memory #(.NTAPS(NTAPS)) ctable(.out(coeffs[(NTAPS*(WIDTH))-1:0]));
    
    //fixed-point DA fir filter
    reg reset;
    reg lrclk_gen;
    reg [(WIDTH-1):0] left_in, right_in;
    wire [23:0] left_out, right_out;
    fir_systolic #(.NTAPS(NTAPS), .WIDTH(WIDTH)) leftfir(.reset(reset), .lrclk(lrclk_gen), .in(left_in[31:8]), .out(left_out[23:0]), .coeffs(coeffs));
    fir_systolic #(.NTAPS(NTAPS), .WIDTH(WIDTH)) rightfir(.reset(reset), .lrclk(lrclk_gen), .in(right_in[31:8]), .out(right_out[23:0]), .coeffs(coeffs));
    
    initial begin
    lrclk_gen=1;
    left_in=0;
    right_in=0;
    reset=1;
    forever #64 lrclk_gen = ~lrclk_gen;
    end
    
    initial begin
    #128
    reset=0;
    left_in = {24'h00_0001, 8'h00};
    right_in = {24'h00_0001, 8'h00};
    #128
    left_in=0;
    right_in=0;
    end
endmodule
