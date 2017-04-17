`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2017 05:23:29 PM
// Design Name: 
// Module Name: better_i2s_rx
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


module better_i2s_rx(
    input wire reset,
    input wire lrclk,
    input wire bclk, 
    input wire sdto,
    output reg[31:0] left_channel,
    output reg[31:0] right_channel
    );
    
    
    reg old_lrclk=0;
    //goes high when lrclk changes
    wire lrclk_change = ~(old_lrclk & lrclk);
    always @(posedge bclk)
    begin
        if (reset)
            begin
            left_channel<=0;
            right_channel<=0;
            old_lrclk<=0;
            end
        else
            begin
            old_lrclk <= lrclk;
                if (lrclk_change)
                    begin
                        //wait 1 cycle
                        if (lrclk==1)
                            begin
                            end
                        else if (lrclk==0)
                            begin
                            left_channel<=0;
                            right_channel<=0;
                            end
                    end
                else
                    begin
                        //shift in a sample
                        if (lrclk)
                            left_channel[31:0] <= {left_channel[30:0], sdto};
                        else
                            right_channel[31:0] <= {right_channel[30:0], sdto};
                    end
            end
    end
endmodule
