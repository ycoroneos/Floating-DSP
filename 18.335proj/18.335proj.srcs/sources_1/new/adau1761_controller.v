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
addr<=ADDR; \
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
input wire ac_lrclk,
input wire ac_bclk,
output wire ac_sdto_dac,
input wire ac_sdto_adc,
output wire ac_scl,
output wire ac_sda,

//input from clockgen
input wire mclk, //i2s mclk
output wire lrclk, //i2slrclk
output wire bclk, //i2sbclk
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
    assign ac_mclk = mclk; //mclk must always be present for the thing to even work
    assign lrclk = ac_lrclk;
    assign bclk = ac_bclk;
    
    //i2c controller
    reg i2cstart=0;
    reg i2cpllstart=0;
    reg usepllcfg=0;
    reg [7:0] addr = 8'h76;
    reg [7:0] reghi, reglo, data, data1, data2, data3, data4, data5;
    wire clk9600, regular_scl, regular_sda, pll_scl, pll_sda;
    assign ac_scl = usepllcfg ? pll_scl : regular_scl;
    assign ac_sda = usepllcfg ? pll_sda : regular_sda;
    assign clk9600=serialclk;
   // divider #(.LOGLENGTH(11), .COUNTVAL(1280)) serialclkmon(.reset(reset), .inclk(mclk), .newclk(clk9600)); //makes 9.6khz clock from 12.288MHz clock
    adau1761i2c configbus(.reset(reset), .serialclk(clk9600), .start(i2cstart), .addr(addr), .reghi(reghi), .reglo(reglo), .data(data), .scl(regular_scl), .sda(regular_sda));
    adau1761plli2c pllconfigbus(.reset(reset), .serialclk(clk9600), .start(i2cpllstart), .addr(addr), .reghi(reghi), .reglo(reglo), .data0(data), .data1(data1), .data2(data2), .data3(data3),
    .data4(data4), .data5(data5), .scl(pll_scl), .sda(pll_sda));
    
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
                addr<=8'h76;
                reghi<=8'h40;
                ready<=0;
                i2cstart<=0;
                i2cpllstart<=0;
                usepllcfg<=0;
            end
        else
            begin
                case(curstate)
                 `I2C_WRITE(8'h76, 8'h40, 8'h00, 8'h0E, 0) // PLL mode
                 
                 //configure the PLL to work off of 24MHz input clock
                2:
                    begin
                    usepllcfg<=1;
                    curstate<=curstate+1;
                    end
                 
                3:
                    begin
                    reglo<=8'h02;
                    data<=8'h00;
                    data1<=8'h7D;
                    data2<=8'h00;
                    data3<=8'h0C;
                    data4<=8'h23;
                    data5<=8'h01;
                    i2cpllstart<=1;
                    curstate<=curstate+1;
                    end
                4:
                    begin
                    i2cpllstart<=0;
                    curstate<=curstate+1;
                    end
                5:
                    begin
                    usepllcfg<=0;
                    curstate<=curstate+1;
                    end
                
               //regular i2s commands
               `I2C_WRITE(8'h00, 8'h00, 8'h00, 8'h00, 3) //wait
               `I2C_WRITE(8'h00, 8'h00, 8'h00, 8'h00, 4) //wait
               `I2C_WRITE(8'h76, 8'h40, 8'h00, 8'h0F, 5) //enable the core
               `I2C_WRITE(8'h76, 8'h40, 8'h15, 8'h01, 6) //become i2s master
               `I2C_WRITE(8'h76, 8'h40, 8'h0A, 8'h01, 7) //enable left mixer
               `I2C_WRITE(8'h76, 8'h40, 8'h0B, 8'h05, 8) //left mixer gain=0db
               `I2C_WRITE(8'h76, 8'h40, 8'h0C, 8'h01, 9) //enable right mixer
               `I2C_WRITE(8'h76, 8'h40, 8'h0D, 8'h05, 10) //right mixer gain=0db
               `I2C_WRITE(8'h76, 8'h40, 8'h1C, 8'h21, 11) //
               `I2C_WRITE(8'h76, 8'h40, 8'h1E, 8'h41, 12)
               `I2C_WRITE(8'h76, 8'h40, 8'h23, 8'hE7, 13)
               `I2C_WRITE(8'h76, 8'h40, 8'h24, 8'hE7, 14)
               `I2C_WRITE(8'h76, 8'h40, 8'h25, 8'hE7, 15)
               `I2C_WRITE(8'h76, 8'h40, 8'h26, 8'hE7, 16)
               `I2C_WRITE(8'h76, 8'h40, 8'h19, 8'h03, 17)
               `I2C_WRITE(8'h76, 8'h40, 8'h29, 8'h03, 18)
               `I2C_WRITE(8'h76, 8'h40, 8'h2A, 8'h03, 19)
               `I2C_WRITE(8'h76, 8'h40, 8'hF2, 8'h01, 20)
               `I2C_WRITE(8'h76, 8'h40, 8'hF3, 8'h01, 21)
               `I2C_WRITE(8'h76, 8'h40, 8'hF9, 8'h7F, 22)
               `I2C_WRITE(8'h76, 8'h40, 8'hFA, 8'h03, 23)
               `I2C_WRITE(8'h00, 8'h00, 8'h00, 8'h00, 24) //wait
                default: ready<=1;
                endcase
            end
    end
    
endmodule
