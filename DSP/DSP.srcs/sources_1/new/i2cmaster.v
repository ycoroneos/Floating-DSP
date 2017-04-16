`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2017 02:35:34 PM
// Design Name: 
// Module Name: i2cmaster
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


module i2cmaster(
input wire reset,   //starts i2c transmission on a falling edge
input wire clk,     //output clock
input wire [80:0] data,  // data is left-justified
input wire [7:0] datacount,
output reg scl=1,    //i2c scl
output reg sda=1     //i2c sda
    );
    //reg [80:0] actual_data;
    //assign actual_data[80:0] = {data[71:64], 1'b1, data[63:56], 1'b1, data[55:48], 1'b0, data[47:40], 1'b0, data[39:18], 1'b0, data[31:17], 1'b0, data[23:16], 1'b0, data[15:8], 1'b0, data[7:0], 1'b0};
    //wire [7:0] tdata = data[71:64];
    reg [7:0] curbit=0;
    reg [5:0] curstate=0;
    parameter RESET=0;
    parameter START_CONDITION = 1;
    parameter SHIFT_OUT = 2;
    parameter STOP_CONDITION = 3;
    parameter WAIT_STATE = 4;
    
    always @*
        begin
            if(curstate==SHIFT_OUT || curstate==STOP_CONDITION)
                begin
                scl=clk;
                end
            else
                begin
                scl=1;
                end
        end
    
    always @(negedge clk)
    begin
        if(reset)
            begin
            curstate<=START_CONDITION;
            sda<=1;
            curbit<=datacount;
            end
        else
            begin
                case(curstate)
                RESET:
                    begin
                    sda<=1;
                    end
                START_CONDITION:
                    begin
                        sda<=0;
                        curstate<=WAIT_STATE;
                        curbit<=datacount;
                    end
                WAIT_STATE:
                    begin
                        curstate<=SHIFT_OUT;
                        sda<=data[80 - (datacount - curbit)];
                        curbit<=curbit-1;
                    end
                SHIFT_OUT:
                    begin
                    sda<=data[80 - (datacount - curbit)];
                        if (curbit==0)
                            begin
                                curstate<=STOP_CONDITION;
                                
                                //sda<=1;
                            end
                        else
                            begin
                                //sda<=data[80 - (datacount - curbit)];
                                curbit<=curbit-1;
                            end
                    end
                STOP_CONDITION:
                    begin
                        sda<=1;
                        curstate<=RESET;
                    end
                endcase
            end
    end
endmodule
