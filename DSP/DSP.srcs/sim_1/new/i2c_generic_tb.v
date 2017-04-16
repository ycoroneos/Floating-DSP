`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2017 03:06:43 PM
// Design Name: 
// Module Name: i2c_generic_tb
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


module i2c_generic_tb(

    );
    
    reg reset, clk;
    reg [7:0] datacount;
    reg [80:0] data;
    wire scl, sda;
    i2cmaster dut(.reset(reset), .clk(clk), .data(data), .datacount(datacount), .scl(scl), .sda(sda));
    
        initial begin
        reset=1'b1;
        clk=0;
        datacount=0;
        data=0;
        forever #10 clk = ~clk;
        end
        
        initial begin
        #100
        datacount=8*9 + 9;
        data={8'h76, 1'b0, 8'h40, 1'b0, 8'h02, 1'b0, 8'h00, 1'b0, 8'h7D, 1'b0, 8'h00, 1'b0, 8'h0C, 1'b0, 8'h23, 1'b0, 8'h01, 1'b0};
        reset=1'b0;
        end
endmodule
