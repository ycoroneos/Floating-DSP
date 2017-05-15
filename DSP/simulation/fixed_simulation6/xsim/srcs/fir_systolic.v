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


//https://www.xilinx.com/support/documentation/ip_documentation/fir_compiler_ds534.pdf
//page 17, figure 5

module fir_systolic # (
parameter NTAPS=5,
parameter WIDTH = 32,
parameter TOP_BIT=23
)
(
input wire reset,
input wire lrclk,
input wire [WIDTH-1:0] in,
input wire [WIDTH-1:0] out,
input wire [(NTAPS)*(WIDTH)-1:0] coeffs
    );
    //constants we need
    localparam NPIPES = 2*(NTAPS-1);
    localparam NDELAYS = NTAPS;
    localparam NADDS = NTAPS-1;
    localparam NMULS = NTAPS;
    
    //declare the pipeline stages
    reg [WIDTH-1:0] pipes[NPIPES-1:0];
    reg [WIDTH-1:0] delays[NDELAYS-1:0];
    
    //declare the continuous stages
    wire signed [WIDTH-1:0] muls[NMULS-1:0];
    wire signed [WIDTH-1:0] adds[NADDS-1:0];
    
    //make the continuous assignments
    genvar j;
    //muls
    for (j=0; j<NMULS; j=j+1)
        begin
            if (j==0)
                begin
                    assign muls[j][WIDTH-1:0] = in[WIDTH-1:0] * coeffs[j*WIDTH +: WIDTH];
                end
            else
                begin
                    assign muls[j][WIDTH-1:0] = pipes[(2*j)-1][WIDTH-1:0] * coeffs[j*WIDTH +: WIDTH];
                end
        end
    //adds
    for (j=0; j<NADDS; j=j+1)
        begin
            assign adds[j][WIDTH-1:0] = delays[j][WIDTH-1:0] + muls[j+1][WIDTH-1:0];
        end
    
    
    
   
    assign out[WIDTH-1:0] = delays[NDELAYS-1][WIDTH-1 -: WIDTH];
    integer i;
    always @(negedge lrclk)
    begin
        if (reset)
        begin
            for (i=0; i<NDELAYS; i=i+1) delays[i]<=0;
            for (i=0; i<NPIPES; i=i+1) pipes[i]<=0;
        end
        else
        begin
            //pipeline
            for (i=0; i<NPIPES; i=i+1)
                begin
                    if (i==0)
                        begin
                            pipes[i][WIDTH-1:0] <= in[WIDTH-1:0];
                        end
                    else
                        begin
                            pipes[i][WIDTH-1:0] <= pipes[i-1][WIDTH-1:0];
                        end
                end
               
            //delays
            for (i=0; i<NDELAYS; i=i+1)
                begin
                    if (i==0)
                        begin
                            delays[i][WIDTH-1:0] <= muls[i][WIDTH-1:0];
                        end
                    else
                        begin
                            delays[i][WIDTH-1:0] <= adds[i-1][WIDTH-1:0];
                        end
                end
        end
    end
endmodule
