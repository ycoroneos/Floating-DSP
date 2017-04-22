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
    output reg[23:0] left_channel=0,
    output reg[23:0] right_channel=0
    );
    
    
    reg old_lrclk=1;
    reg [31:0] l=0;
    reg [31:0] r=0;
    //goes high when lrclk changes
    wire lrclk_change = !(lrclk == old_lrclk);
    always @(posedge bclk)
    begin
        if (reset)
            begin
            left_channel<=0;
            right_channel<=0;
            l<=0;
            r<=0;
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
                            left_channel<=l[30:7];
                            right_channel<=r[30:7];
                            end
                        //shift in the first sample
                        if (lrclk)
                            begin
                                r[31:0] <= {30'h0, sdto};
                            end
                        else 
                            begin
                                l[31:0] <= {30'h0, sdto};
                            end
                    end
                else
                    begin
                        //shift in a sample
                        if (lrclk)
                            r[31:0] <= {r[30:0], sdto};
                        else
                            l[31:0] <= {l[30:0], sdto};
                    end
            end
    end
endmodule