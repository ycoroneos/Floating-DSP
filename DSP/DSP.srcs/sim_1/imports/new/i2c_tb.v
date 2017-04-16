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
    reg reset, serialclk, mclk, fsmclk, start;
    //reg [7:0] addr, reghi, reglo, data;
    wire scl, sda, ac_mclk;
    adau1761_controller dut(.reset(reset), .ac_mclk(ac_mclk), .mclk(mclk), .serialclk(serialclk), .fsmclk(fsmclk), .ac_scl(scl), .ac_sda(sda));
    //adau1761i2c i2cdut(.reset(reset), .serialclk(serialclk), .start(start), .addr(addr), .reghi(reghi), .reglo(reglo), .data(data), .scl(scl), .sda(sda));
    
    initial begin
    reset=1'b1;
    serialclk=1'b0;
    mclk=1'b0;
    fsmclk=1'b0;
    start=1'b0;
    
    forever #10 mclk = ~mclk;
    end
    
    initial begin
    forever #10 serialclk = ~serialclk;
    end
    
    initial begin
    forever #10000 fsmclk = ~fsmclk;
    end
    
    initial begin
    reset=1'b1;
    #100
    reset=1'b0;
   
    end
endmodule
