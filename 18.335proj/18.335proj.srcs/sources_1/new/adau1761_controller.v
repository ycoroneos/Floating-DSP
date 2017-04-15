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

`define I2C_WRITE(ADDR, REGHI, REGLO, DATA, NUM)\
((NUM*2)+0):\
begin\
i2cstart<=1; \
reglo<=REGLO; \
reghi<=REGHI; \
data<=DATA; \
curstate<=curstate+1; \
end \
((NUM*2)+1): \
begin \
i2cstart<=0; \
curstate<=curstate+1; \
end \

module adau1761_controller(

//reset
input wire reset,

//input/output to device
output wire ac_mclk,
output wire ac_lrclk,
output wire ac_bclk,
output wire ac_sdto_dac,
input wire ac_sdto_adc,
output wire ac_scl,
inout wire ac_sda,

//input from clockgen
input wire mclk, //i2s mclk
input wire lrclk, //i2slrclk
input wire bclk, //i2sbclk
input wire fsmclk, //state machine clock

//input/output from DSP modules
input wire sdto_to_codec,
output wire sdto_from_codec,

//indicators
output reg ready
    );
    
    //wire the i2s together
    assign sdto_from_codec = ready ? ac_sdto_adc : 1'b0;
    assign ac_stdo_dac = ready ? sdto_to_codec : 1'b0;
    assign ac_mclk = mclk; //mclk must always be present for the thing to even work
    assign ac_lrclk = lrclk;
    assign ac_bclk = bclk;
    
    //i2c controller
    reg i2cstart=0;
    reg [7:0] addr, reghi, reglo, data;
    wire clk9600;
    divider #(.LOGLENGTH(11), .COUNTVAL(1280)) serialclkmon(.reset(reset), .inclk(mclk), .newclk(clk9600)); //makes 9.6khz clock from 12.288MHz clock
    adau1761i2c configbus(.reset(reset), .serialclk(clk9600), .start(i2cstart), .addr(addr), .reghi(reghi), .reglo(reglo), .data(data), .scl(ac_scl), .sda(ac_sda));
    
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
    reg [5:0] curstate=0;
    always @(posedge fsmclk)
    begin
        if (reset)
            begin
                curstate<=0;
                addr<=8'h76;
                reghi<=8'h40;
                ready<=0;
            end
        else
            begin
                case(curstate)
                `I2C_WRITE(8'h76, 8'h40, 8'h00, 8'h01, 0)
                `I2C_WRITE(8'h76, 8'h40, 8'h0A, 8'h01, 1)
                `I2C_WRITE(8'h76, 8'h40, 8'h0B, 8'h05, 2)
                `I2C_WRITE(8'h76, 8'h40, 8'h0C, 8'h01, 3)
                `I2C_WRITE(8'h76, 8'h40, 8'h0D, 8'h05, 4)
                `I2C_WRITE(8'h76, 8'h40, 8'h1C, 8'h21, 5)
                `I2C_WRITE(8'h76, 8'h40, 8'h1E, 8'h41, 6)
                `I2C_WRITE(8'h76, 8'h40, 8'h23, 8'hE7, 7)
                `I2C_WRITE(8'h76, 8'h40, 8'h24, 8'hE8, 8)
                `I2C_WRITE(8'h76, 8'h40, 8'h15, 8'h01, 9)
                `I2C_WRITE(8'h76, 8'h40, 8'h19, 8'h03, 9)
                `I2C_WRITE(8'h76, 8'h40, 8'h29, 8'h03, 10)
                `I2C_WRITE(8'h76, 8'h40, 8'h2A, 8'h03, 11)
                `I2C_WRITE(8'h76, 8'h40, 8'hF2, 8'h01, 12)
                `I2C_WRITE(8'h76, 8'h40, 8'hF3, 8'h01, 13)
                `I2C_WRITE(8'h76, 8'h40, 8'hF9, 8'h7F, 14)
                `I2C_WRITE(8'h76, 8'h40, 8'hFA, 8'h03, 15)
                default: ready<=1;
                endcase
            end
    end
endmodule
