`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2017 11:02:06 PM
// Design Name: 
// Module Name: i2s_sim
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


module i2s_sim(

    );
    
   reg [23:0] left_input;
   reg [23:0] right_input; 
   reg lrclk=0;
   reg bclk=0;
   reg reset=0;
   wire sdto;
   wire real_lrclk;
   wire [23:0] left_output;
   wire [23:0] right_output;
   
   delay_1 d(.reset(reset), .fastclk(bclk), .slowclk(lrclk), .newclk(real_lrclk));
   
   better_i2s_tx tx(.reset(reset), .lrclk(real_lrclk), .bclk(bclk), .sdto(sdto), .left_channel(left_input), .right_channel(right_input));
   
   better_i2s_rx rx(.reset(reset), .lrclk(real_lrclk), .bclk(bclk), .sdto(sdto), .left_channel(left_output), .right_channel(right_output));
    
    initial begin
    reset=1;
    bclk=1;
    lrclk=1;
    forever #1 bclk=~bclk;
    end
    
    initial begin
    //#1
    forever #64 lrclk=~lrclk;
    end
    
    initial begin
     reset=0;
     left_input = 24'h234567;
     right_input = 24'habcdef;
    #256
    
        left_input = 24'h234567;
        right_input = 24'habcdef;
        #128
        left_input = 24'hcafeba;
        right_input = 24'hbeefba;
        #128
        left_input = 24'h234567;
        right_input = 24'habcdef;
        #128
        left_input = 24'haaaaaa;
       right_input = 24'hbbbbbb;
       #128
       left_input = 24'hddddd;
       right_input = 24'hababab;
       #128
       left_input = 24'h987654;
       right_input = 24'hdeebda;
       
        
    end
    
endmodule
