`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2017 05:33:18 PM
// Design Name: 
// Module Name: better_i2s_tx
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


module better_i2s_tx(
    input wire reset,
    input wire lrclk,
    input wire bclk, 
    output reg sdto=0,
    input wire[31:0] left_channel,
    input wire[31:0] right_channel
    );
    reg old_lrclk=0;
    //goes high when lrclk changes
    wire lrclk_change = ~(old_lrclk & lrclk);
    
    reg [5:0] bitcnt=0;
    reg [31:0] left_channel_sample=0;
    reg [31:0] right_channel_sample=0;
    always @(posedge bclk)
    begin
        if (reset)
            begin
            left_channel_sample<=0;
            right_channel_sample<=0;
            old_lrclk<=0;
            sdto<=0;
            bitcnt<=32;
            end
        else
            begin
            old_lrclk <= lrclk;
                if (lrclk_change)
                    begin
                        //wait 1 cycle
                        bitcnt<=32;
                        if (lrclk==0)
                            begin
                            left_channel_sample[31:0] <= left_channel[31:0];
                            right_channel_sample[31:0] <= right_channel[31:0];
                            end
                        else if (lrclk==1)
                            begin
                            end
                    end
                else
                    begin
                        bitcnt<=bitcnt-1;
                        if (bitcnt==0)
                            begin
                                //crash
                            end
                        else
                            begin
                                sdto <= lrclk ? left_channel_sample[bitcnt-1] : right_channel_sample[bitcnt-1];
                            end
                    end
            end
    end
endmodule
