`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2017 05:57:05 PM
// Design Name: 
// Module Name: i2c_tb
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


module i2c_tb(

    );
    reg reset, serialclk, start;
    reg [7:0] addr, reghi, reglo, data;
    wire scl, sda;
    adau1761i2c i2cdut(.reset(reset), .serialclk(serialclk), .start(start), .addr(addr), .reghi(reghi), .reglo(reglo), .data(data), .scl(scl), .sda(sda));
    
    initial begin
    reset=1'b1;
    serialclk=1'b0;
    start=1'b0;
    addr=8'h00;
    reghi=8'h00;
    reglo=8'h00;
    data=8'h00;
    forever #10 serialclk = ~serialclk;
    end
    
    initial begin
    reset=1'b1;
    #100
    reset=1'b0;
    start=1'b1;
    addr=8'h76;
    reghi=8'h40;
    reglo=8'h19;
    data=8'h03;
    #100
    start=1'b0;
    #1000
    start=1'b1;
    addr=8'h76;
    reghi=8'h40;
    reglo=8'h2A;
    data=8'h03;
    #100
    start=1'b0;
    end
endmodule
