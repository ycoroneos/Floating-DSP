`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2017 02:40:10 PM
// Design Name: 
// Module Name: divider
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

module divider(
input wire inclk, reset,
output wire newclk
    );
    parameter LOGLENGTH=31;
    parameter COUNTVAL=100000;
    reg [LOGLENGTH:0] count=0;
    reg output_reg=0;
    assign newclk=output_reg;
    always @(posedge inclk)
    begin
    if (reset)
        begin
        count <=0;
        output_reg<=0;
        end
    else
        begin
        if (count==COUNTVAL)
            begin
            count<=0;
            output_reg<=~output_reg;
            end
        else
            count<=count+1;
        end
    end
endmodule