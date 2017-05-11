`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2017 08:45:38 PM
// Design Name: 
// Module Name: firtb
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

module fir_floatingtb(

    );
    //memory for the filter coefficients
    localparam NTAPS=208;
    localparam WIDTH=32;
    wire [(NTAPS*(WIDTH))-1 : 0] coeffs;
    float_memory #(.NTAPS(NTAPS)) ctable(.out(coeffs[(NTAPS*(WIDTH))-1:0]));

    integer file;

    //fixed-point DA fir filter
    // reg reset;
    // reg lrclk_gen;
    // reg [(WIDTH-1):0] left_in, right_in;
    // wire [23:0] left_out, right_out;
    // fir_systolic #(.NTAPS(NTAPS), .WIDTH(WIDTH)) leftfir(.reset(reset), .lrclk(lrclk_gen), .in(left_in[31:8]), .out(left_out[23:0]), .coeffs(coeffs));
    // fir_systolic #(.NTAPS(NTAPS), .WIDTH(WIDTH)) rightfir(.reset(reset), .lrclk(lrclk_gen), .in(right_in[31:8]), .out(right_out[23:0]), .coeffs(coeffs));

    //floating-point DA fir filter
    reg reset;
    reg lrclk_gen;
    reg fastclk_gen;
    reg [(WIDTH-1):0] left_in, right_in;
    wire [31:0] left_out, right_out;
    fir_floating #(.NTAPS(NTAPS), .WIDTH(WIDTH)) leftfir(.reset(reset), .lrclk(lrclk_gen), .fastclk(fastclk_gen), .in(left_in[31:0]), .out(left_out[31:0]), .coeffs(coeffs));
    fir_floating #(.NTAPS(NTAPS), .WIDTH(WIDTH)) rightfir(.reset(reset), .lrclk(lrclk_gen), .fastclk(fastclk_gen), .in(right_in[31:0]), .out(right_out[31:0]), .coeffs(coeffs));
    
    initial begin
    file=$fopen("output.txt","w");
    $display("Opened file descriptor: %d",file);
    $fwrite(file, "Output data...");
        
    lrclk_gen=1;
    left_in=0;
    right_in=0;
    reset=1;
    forever #100 lrclk_gen = ~lrclk_gen;
    end

    initial begin
    fastclk_gen=0;
    forever #1 fastclk_gen = ~fastclk_gen;
    end
    
    always @(negedge lrclk_gen)
    begin
    $fwrite(file,"%b\n",left_out);
    end

    initial begin
    // this value should be 200*[number of output samples to save]
    #100000 $fclose(file);
    $finish;
    end

    // initial begin
    // #1920
    // reset=0;
    // end
    
    initial begin
    // #1280
    #200
    reset=0;
    left_in = 32'b00111111100000000000000000000000;
    right_in = 32'b00111111100000000000000000000000;
    #200
    // #1280
    // #2560
    left_in=0;
    right_in=0;
    end
endmodule
