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
parameter TAPS=5,
parameter WIDTH = 32,
parameter TOP_BIT=31
)
(
input wire reset,
input wire lrclk,
input wire [23:0] in,
input wire [23:0] out,
input wire [(TAPS-1)*(WIDTH-1):0] coeffs
    );
    
    reg [WIDTH-1:0] result;
    reg [23:0] pipes[(TAPS-2)*2:0];
    reg [WIDTH-1:0] adds[(TAPS-2):0];
    reg [WIDTH-1:0] muls[TAPS-1:0];
    reg [WIDTH-1:0] acc[TAPS-1:0];
    assign out[23:0] = result[TOP_BIT:(TOP_BIT-23)];
    integer i;
    always @(negedge lrclk)
    begin
        if (reset)
        begin
            result <= 0;
            for (i=0; i<(TAPS-1)*2; i=i+1) pipes[i]<=0;
            for (i=0; i<(TAPS-1); i=i+1) adds[i]<=0;
            for (i=0; i<TAPS; i=i+1) muls[i]<=0;
        end
        else
        begin
            //do the pipeline thing
            for (i=0; i<(TAPS-1)*2; i=i+1)
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
            
            //compute the adds
            for (i=0; i<(TAPS-1)/2; i=i+1)
                begin
                    if (i==0)
                        begin
                            adds[i][WIDTH-1:0] <= {{(WIDTH-24-1){1'b0}}, in[23:0]} + adds[((TAPS-1)/2)-i][WIDTH-1:0];
                        end
                    else
                        begin
                            adds[i][WIDTH-1:0] <= adds[i][WIDTH-1:0] + adds[((TAPS-1)/2)-i][WIDTH-1:0];
                        end
                end
            
            //compute the muls
            for (i=0; i<TAPS; i=i+1)
                begin
                    if (i==(TAPS-1))
                        begin
                            muls[i][WIDTH-1:0] <= {{(WIDTH-24-1){1'b0}},pipes[TAPS-1][23:0]};
                        end
                    else
                        begin
                            muls[i][WIDTH-1:0] <= adds[i][WIDTH-1:0] * coeffs[31:0];
                        end
                end
            
            //compute the accs
            for (i=1; i<TAPS-1; i=i+1)
                begin
                    if (i==1)
                        begin
                            acc[i][WIDTH-1:0] <= muls[i][WIDTH-1:0] + muls[i-1][WIDTH-1:0];
                        end
                    else
                        begin
                            acc[i][WIDTH-1:0] <= muls[i][WIDTH-1:0] + acc[i-1][WIDTH-1:0];
                        end
                end
                result[WIDTH-1:0] <= acc[TAPS-1][WIDTH-1:0];
        end
    end
endmodule
