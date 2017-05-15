`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2015 11:53:01 PM
// Design Name: 
// Module Name: bicksync
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


module clock_sync(
input wire fastclk,
input wire slowclk,
input wire reset,
output reg ready=0
    );
    reg [1:0] memory=2'b00;
    always @(fastclk)
        begin
        if (reset)
            memory<=2'b00;
        memory<={memory[0],slowclk};
        end
    always @*
    begin
        if (memory=={1'b1, 1'b0})
            ready=1;
        else
            ready=0;
    end
endmodule
