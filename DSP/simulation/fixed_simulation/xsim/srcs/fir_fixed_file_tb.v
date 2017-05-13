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

module fir_fixed_file_tb(

    );
    //memory for the filter coefficients
    // localparam NTAPS=208;
    localparam NTAPS=107;
    localparam WIDTH=50;
    wire [(NTAPS*(WIDTH))-1 : 0] coeffs;
    memory #(.NTAPS(NTAPS), .WIDTH(WIDTH)) ctable(.out(coeffs[(NTAPS*(WIDTH))-1:0]));

    reg [32:0] progress;
    integer fixed_output_fd, fixed_input_fd;

    //fixed-point DA fir filter
    reg reset;
    reg lrclk_gen;
    reg [(WIDTH-1):0] left_in;
    wire [(WIDTH-1):0] left_out;
    fir_systolic #(.NTAPS(NTAPS), .WIDTH(WIDTH)) leftfir(.reset(reset), .lrclk(lrclk_gen), .in(left_in), .out(left_out), .coeffs(coeffs));

    //open a bunch of files
    initial begin
        fixed_input_fd=$fopen("chirp_fixed_binary.mem","r");
        fixed_output_fd=$fopen("fixed_output.mem", "w");
    end
    // 11111111111111111111111111111110000011110000000000
    initial begin
      progress=0;
    lrclk_gen=1;
    left_in=0;
    reset=1;
    forever #64 lrclk_gen = ~lrclk_gen;
    end

    initial begin
    #128
    reset=0;
    end
    
    //load in a new input on every rising lrclk edge
    always @(posedge lrclk_gen)
    begin
        if ($feof(fixed_input_fd)) begin
        //close all open fds
        $fclose(fixed_input_fd);
        $fclose(fixed_output_fd);
        $finish;
        end
        progress = progress + 1;
        $fscanf(fixed_input_fd, "%b\n", left_in);
    end
    
    //write data to files   
    always @(negedge lrclk_gen)
    begin
        $fwrite(fixed_output_fd,"%b\n",left_out);
        $display("%d\n", progress);
    end
endmodule
