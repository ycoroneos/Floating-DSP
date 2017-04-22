`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2017 01:08:16 AM
// Design Name: 
// Module Name: delay_1
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


module delay_1(
input wire reset,
input wire fastclk,
input wire slowclk,
output reg newclk=0
    );
    always @(negedge fastclk)
    begin
        if (reset)
        begin
            newclk<=0;
        end
        else
            begin
                newclk<=slowclk;
            end
    end
endmodule
