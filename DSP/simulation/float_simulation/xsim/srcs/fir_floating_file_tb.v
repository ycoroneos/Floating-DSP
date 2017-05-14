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

module fir_floating_file_tb(

    );
    //memory for the filter coefficients
    // localparam NTAPS=208;
    localparam NTAPS=107;
    localparam WIDTH=32;
    wire [(NTAPS*(WIDTH))-1 : 0] coeffs;
    float_memory #(.NTAPS(NTAPS)) ctable(.out(coeffs[(NTAPS*(WIDTH))-1:0]));

    //floating-point DA fir filter
    reg reset;
    reg lrclk_gen;
    reg fastclk_gen;
    reg [(WIDTH-1):0] left_in;
    wire [31:0] left_out;
    fir_floating #(.NTAPS(NTAPS), .WIDTH(WIDTH)) leftfir(.reset(reset), .lrclk(lrclk_gen), .fastclk(fastclk_gen), .in(left_in[31:0]), .out(left_out[31:0]), .coeffs(coeffs));
    
    // for sanity
    reg [32:0] progress;
    integer float_input_fd, float_output_fd;

    initial begin        
    lrclk_gen=1;
    left_in=0;
    reset=1;
    forever #200 lrclk_gen = ~lrclk_gen;
    end

    initial begin
    fastclk_gen=0;
    forever #1 fastclk_gen = ~fastclk_gen;
    end

    initial begin
    #400
    reset=0;
    progress=0;
    end

    //open a bunch of files
    initial begin
        float_input_fd=$fopen("chirp_float_binary.mem","r");
        float_output_fd=$fopen("float_output.mem", "w");
    end
    
    //load in a new input on every rising lrclk edge
    always @(posedge lrclk_gen)
    begin
        if ($feof(float_input_fd)) begin
        //close all open fds
        $fclose(float_input_fd);
        $fclose(float_output_fd);
        $finish;
        end
        progress = progress + 1;
        $fscanf(float_input_fd, "%b\n", left_in);
    end
    
    //write data to files   
    always @(negedge lrclk_gen)
    begin
        $fwrite(float_output_fd,"%b\n",left_out);
        $display("%d\n", progress);
    end
endmodule
