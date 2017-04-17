`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2017 11:45:49 AM
// Design Name: 
// Module Name: adau1761_controller
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

`define I2C_WRITE(ADDR, REGHI, REGLO, BYTE0, BYTE1, BYTE2, BYTE3, BYTE4, BYTE5, NBYTES, CASENUM)\
((CASENUM*2)+0):\
begin\
i2cstart<=0; \
i2cdatacount<= (3+NBYTES)*8 + 3+NBYTES; \
i2cdata<={ADDR, 1'b0, REGHI, 1'b0, REGLO, 1'b0, BYTE0, 1'b0, BYTE1, 1'b0, BYTE2, 1'b0, BYTE3, 1'b0, BYTE4, 1'b0, BYTE5, 1'b0}; \
curstate<=curstate+1; \
end \
((CASENUM*2)+1): \
begin \
i2cstart<=1; \
curstate<=curstate+1; \
end \

`define I2C_WAIT(CASENUM) \
((CASENUM*2)+0): curstate<=curstate+1;\
((CASENUM*2)+1): curstate<=curstate+1;\

module adau1761_controller(

//reset
input wire reset,

//input/output to device
output wire ac_mclk,
input wire ac_lrclk,
input wire ac_bclk,
output wire ac_sdto_dac,
input wire ac_sdto_adc,
output wire ac_scl,
output wire ac_sda,

//input from clockgen
input wire mclk, //i2s mclk
input wire lrclk, //i2slrclk
input wire bclk, //i2sbclk
input wire fsmclk, //state machine clock
input wire serialclk, //scl clock for i2c

//input/output from DSP modules
input wire sdto_to_codec,
output wire sdto_from_codec,

//indicators
output reg ready=0
    );
    
    //wire the i2s together
    assign sdto_from_codec = ac_sdto_adc;
    assign ac_sdto_dac = sdto_to_codec;
    assign ac_mclk = mclk;
    assign lrclk = ac_lrclk;
    assign bclk = ac_bclk;
    
    //i2c controller
    reg i2cstart=1; //active low
    reg [80:0] i2cdata=0;
    reg [7:0] i2cdatacount=0;
    i2cmaster adaui2c(.reset(i2cstart), .clk(serialclk), .data(i2cdata), .datacount(i2cdatacount), .scl(ac_scl), .sda(ac_sda));
    
    //fsm stuff
    /*
    // 0x4000=0x1 -> enable core clock
    // 0x400A=0x1 -> left Aux input
    // 0x400B=0x5 ^ditto
    // 0x400C=0x1 -> right Aux input
    // 0x400D=0x5 ^ditto
    // 0x401C=0x21 -> left headphone out
    // 0x401E=0x41 -> right headphone out
    // 0x4023=0xE7 -> left headphone gain 0db
    // 0x4024=0xE7 -> right headphone gain 0db
    // 0x4019=0x3 -> all ADCs on
    // 0x4029=0x3 -> L/R playback enable
    // 0x402A=0x3 -> both DACs enabled
    // 0x40F2=0x1 -> i2s input is channel 1
    // 0x40F3=0x1 -> i2s output is channel 1
    // 0x40F9=0x7F -> all modules power on
    // 0x40FA=0x3 -> enable both digital clocks
    */
   reg [7:0] curstate=0;
    always @(posedge fsmclk)
    begin
        if (reset)
            begin
                curstate<=0;
                ready<=0;
                i2cstart<=1;
            end
        else
            begin
                case(curstate)
                 
                 
                 
               `I2C_WAIT(0)
               `I2C_WRITE(8'h76, 8'h40, 8'h00, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1, 1) //enable the core
               `I2C_WRITE(8'h76, 8'h40, 8'h0A, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,2) //enable left mixer
               `I2C_WRITE(8'h76, 8'h40, 8'h0B, 8'h05, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,3) //left mixer gain=0db
               `I2C_WRITE(8'h76, 8'h40, 8'h0C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,4) //enable right mixer
               `I2C_WRITE(8'h76, 8'h40, 8'h0D, 8'h05, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,5) //right mixer gain=0db
               `I2C_WRITE(8'h76, 8'h40, 8'h1C, 8'h21, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,6) //
               `I2C_WRITE(8'h76, 8'h40, 8'h1E, 8'h41, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,7)
               `I2C_WRITE(8'h76, 8'h40, 8'h23, 8'hE7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,8)
               `I2C_WRITE(8'h76, 8'h40, 8'h24, 8'hE7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,9)
               `I2C_WRITE(8'h76, 8'h40, 8'h25, 8'hE7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,10)
               `I2C_WRITE(8'h76, 8'h40, 8'h26, 8'hE7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,11)
               `I2C_WRITE(8'h76, 8'h40, 8'h19, 8'h03, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,12)
               `I2C_WRITE(8'h76, 8'h40, 8'h29, 8'h03, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,13)
               `I2C_WRITE(8'h76, 8'h40, 8'h2A, 8'h03, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,14)
               `I2C_WRITE(8'h76, 8'h40, 8'hF2, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,15)
               `I2C_WRITE(8'h76, 8'h40, 8'hF3, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,16)
               `I2C_WRITE(8'h76, 8'h40, 8'hF9, 8'h7F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,17)
               `I2C_WRITE(8'h76, 8'h40, 8'hFA, 8'h03, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1,18)
               `I2C_WAIT(19)
                default: ready<=1;
                endcase
            end
    end
    
endmodule
