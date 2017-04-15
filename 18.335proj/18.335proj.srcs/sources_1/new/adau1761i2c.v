`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2017 12:05:07 PM
// Design Name: 
// Module Name: adau1761i2c
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

// This implements a highly modified i2c protocol which is meant just for the adau1761
// there is no slave response, the input is always 35 bits, and there is no ACK check
//

module adau1761i2c(
input wire reset,
input wire serialclk,
input wire start,
input wire[7:0] addr, reghi, reglo, data,
//input wire[34:0] data,
output reg scl,
output reg sda
    );
     parameter DATACOUNT=34;
     parameter RESET_STATE=3'b000;
     parameter WAITFOR_START_STATE=3'b001;
     parameter OUTPUT_STATE=3'b011;
     parameter WAITFOR_NOSTART=3'b100;
     parameter END_CONDITION=3'b110;
     reg [3:0] curstate=RESET_STATE;
     reg [6:0] count=DATACOUNT;
     
     //heres the hack!
     wire[34:0] outdata = {addr[7:0], reghi[7:0], 1'b0, reglo[7:0], 1'b0, data[7:0], 1'b0};
     
     //scl idles high
    always @*
     begin
         if (curstate==OUTPUT_STATE)
             scl=serialclk;
         else
             scl=1;
     end
     
     always @(negedge serialclk)
     begin
        if (reset)
            begin
            curstate <= RESET_STATE;
            count<=0;
            sda<=0;
            end
        else
            begin
                case(curstate)
                RESET_STATE:
                    begin
                    count<=0;
                    curstate<=WAITFOR_START_STATE;
                    sda<=0;
                    end
                WAITFOR_START_STATE:
                    begin
                        if (start)
                            begin
                            curstate<=OUTPUT_STATE;
                            count<=count+1;
                            sda<=outdata[DATACOUNT-count];
                            end
                    end
                OUTPUT_STATE:
                    begin
                        count<=count+1;
                        if (count==(DATACOUNT+1))
                            begin
                                curstate<=WAITFOR_NOSTART;
                            end
                        else
                            begin
                                sda<=outdata[DATACOUNT-count];
                            end
                     end
                WAITFOR_NOSTART:
                    begin
                        //at this point scl is already high
                        //so make sda high now
                        sda<=1;
                        if (~start)
                            curstate<=RESET_STATE;
                    end
                endcase
            end
     end
endmodule
