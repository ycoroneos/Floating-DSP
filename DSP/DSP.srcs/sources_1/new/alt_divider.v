`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2017 02:50:56 PM
// Design Name: 
// Module Name: alt_divider
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


module alt_divider(
input wire reset,
input wire inclk,
output reg outclk=0
    );
    parameter DIV_RATE = 2;
    parameter LOGLENGTH=31;
    reg [LOGLENGTH:0] count=0;
    always @(posedge inclk)
    begin
    if (reset)
        begin
        count <=0;
        outclk<=0;
        end
    else if (count == ((DIV_RATE/2)-1))
        begin
        count <= 0;
        outclk <= ~outclk;
        end
    else
        begin
        count <= count + 1;
        end
    end
endmodule
