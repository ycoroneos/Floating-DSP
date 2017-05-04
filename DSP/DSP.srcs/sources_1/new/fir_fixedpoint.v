`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2017 02:23:46 AM
// Design Name: 
// Module Name: fir_fixedpoint
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


module fir_fixedpoint # (
parameter NTAPS=5,
parameter WIDTH = 32,
parameter TOP_BIT=23
)
(
input wire reset,
input wire lrclk,
input wire [23:0] in,
input wire [23:0] out,
input wire [(NTAPS)*(WIDTH)-1:0] coeffs
    );
    //constants we need
    localparam NDELAY = (NTAPS-1)*2;
    localparam NADDS = NTAPS-1;
    localparam NMULS = NTAPS;
    localparam NACC = NTAPS-1;
    
    //declare the pipeline stages
    //reg [WIDTH-1:0] result;
    reg [23:0] pipes[NDELAY-1:0];
    reg [23:0] pp[NTAPS-1:0];
    reg [WIDTH-1:0] adds[NADDS-1:0];
    reg [WIDTH-1:0] muls[NMULS-1:0];
    reg [WIDTH-1:0] acc[NACC-1:0];
    reg [(WIDTH-1):0] result;
    //assign out[23:0] = result[TOP_BIT -: 24];
    assign out[23:0] = acc[NTAPS-2][TOP_BIT -: 24];
    integer i;
    always @(negedge lrclk)
    begin
        if (reset)
        begin
            result<=0;
            for (i=0; i<NDELAY; i=i+1) pipes[i]<=0;
            for (i=0; i<NTAPS; i=i+1) pp[i]<=0;
            for (i=0; i<NADDS; i=i+1) adds[i]<=0;
            for (i=0; i<NMULS; i=i+1) muls[i]<=0;
            for (i=0; i<NACC; i=i+1) acc[i]<=0;
        end
        else
        begin
            //do the pipeline thing
            for (i=0; i<NDELAY; i=i+1)
                begin
                    if (i==0)
                        begin
                            pipes[0][23:0] <= in[23:0];
                        end
                    else
                        begin
                            pipes[i][23:0] <= pipes[i-1][23:0];
                        end
                end
            
            //delays for the middle element
            for (i=0; i<NTAPS; i=i+1)
                begin
                    if (i==0)
                        begin
                            pp[i][23:0] <= pipes[NTAPS-2][23:0];
                        end
                    else
                        begin
                            pp[i][23:0] <= pp[i-1][23:0];
                        end
                end
            
            //compute the adds
            for (i=0; i<NADDS; i=i+1)
                begin
                    if (i==0)
                        begin
                            adds[i][WIDTH-1:0] <= {{(WIDTH-24-1){1'b0}}, in[23:0]} + {{(WIDTH-24-1){1'b0}}, pipes[NDELAY-1-i][23:0]};
                        end
                    else
                        begin
                            adds[i][WIDTH-1:0] <= {{(WIDTH-24-1){1'b0}}, pipes[i-1[23:0]} + {{(WIDTH-24-1){1'b0}}, pipes[NDELAY-1-i][23:0]};
                        end
                end
            
            //compute the muls
            for (i=0; i<NMULS; i=i+1)
                begin
                    if (i==(NTAPS-1))
                        begin
                            muls[i][WIDTH-1:0] <= {{(WIDTH-24-1){1'b0}},pp[NTAPS-1][23:0]} * coeffs[((i)*(WIDTH-1)) +: (WIDTH)];
                        end
                    else
                        begin
                            muls[i][WIDTH-1:0] <= adds[i][WIDTH-1:0] * coeffs[((i)*(WIDTH-1)) +: (WIDTH)];
                        end
                end
            
            //compute the accs
            for (i=0; i<NACC; i=i+1)
                begin
                    if (i==0)
                        begin
                            acc[i][WIDTH-1:0] <= muls[i][WIDTH-1:0] + muls[i+1][WIDTH-1:0];
                        end
                    else
                        begin
                            acc[i][WIDTH-1:0] <= muls[i+1][WIDTH-1:0] + acc[i-1][WIDTH-1:0];
                        end
                end
                //result[(WIDTH-1):0] <= acc[NTAPS-2][(WIDTH-1):0];
                //result[WIDTH-1:0] <= acc[TAPS-1][WIDTH-1:0];
                
        end
    end
endmodule
