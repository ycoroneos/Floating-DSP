`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: the chronic
// Engineer: sl1m sh4dy
// 
// Create Date: 05/10/2017 11:36:21 PM
// Design Name: 
// Module Name: OGTestBench
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


module OGTestBench(
    );
    
    //fir parameters
    localparam NTAPS=5;
    localparam WIDTH=32;
    
    //fir memories
    wire [(NTAPS*(WIDTH))-1 : 0] fixed_coeffs, float_coeffs;
    memory #(.NTAPS(NTAPS), .FILE("100_LP_binary.coe")) ctable0(.out(float_coeffs[(NTAPS*(WIDTH))-1:0]));
    memory #(.NTAPS(NTAPS), .FILE("float_coeff_100LP_binary.coe")) ctable1(.out(fixed_coeffs[(NTAPS*(WIDTH))-1:0]));
    
    // for sanity
    reg [32:0] progress;

    //signals everyone shares
    reg reset;
    reg lrclk_gen;
    reg fastclk_gen;
    reg [(WIDTH-1):0] left_in_fixed, left_in_float;
    wire [31:0] left_out_float, left_out_fixed;
    assign left_out_fixed[31:24]=0;
    
    //declare the fixed point fir
    fir_systolic #(.NTAPS(NTAPS), .WIDTH(WIDTH)) fixedfir(.reset(reset), .lrclk(lrclk_gen), .in(left_in_fixed[23:0]), .out(left_out_fixed[23:0]), .coeffs(fixed_coeffs));
    
    //declare the floating point fir
    //there also needs to be an Int -> Float converter for the signal input
    fir_floating #(.NTAPS(NTAPS), .WIDTH(WIDTH)) leftfir(.reset(reset), .lrclk(lrclk_gen), .fastclk(fastclk_gen), .in(left_in_float[31:0]), .out(left_out_float[31:0]), .coeffs(float_coeffs));
    
    //variables for file io
    integer float_input_fd, fixed_input_fd, fixed_output_fd, float_output_fd;
    reg [31:0] next_fixed, next_float;
    //scan_file = $fscanf(data_file, "%d\n", captured_data); 
    
    //initialize lrclk
    initial begin
        progress = 1;
        lrclk_gen = 1;
        forever #64 lrclk_gen = ~lrclk_gen;
    end
    
    //initialize the fast floating-point clock
    initial begin
    fastclk_gen=0;
    forever #1 fastclk_gen = ~fastclk_gen;
    end
    
    //this is the main stimulus block
    initial begin
    //initialize state of the input signals
    reset=1;
    left_in_fixed=0;
    left_in_float=0;
    
    //wait until the first rising edge of lrclk to start loading data
    #128
    reset=0;
    left_in_fixed={24'h00_0001, 8'h00};
    #128
    left_in_fixed=0;

    end
    
    //open a bunch of files
    initial begin
        float_input_fd=$fopen("chirp_float_binary.mem","r");
        fixed_input_fd=$fopen("chirp_fixed_binary.mem","r");
        fixed_output_fd=$fopen("chirp_fixed.out", "w");
        float_output_fd=$fopen("chirp_float.out", "w");
    end
    
    //load in a new input on every rising lrclk edge
    always @(posedge lrclk_gen)
    begin
        if ($feof(fixed_input_fd)) begin
        //close all open fds
        $fclose(fixed_input_fd);
        $fclose(float_input_fd);
        $fclose(fixed_output_fd);
        $fclose(float_output_fd);
        $finish;
        end
        progress = progress + 1;
        $fscanf(fixed_input_fd, "%b\n", left_in_fixed);
        $fscanf(float_input_fd, "%b\n", left_in_float);
    end
    
    //write data to files   
    always @(negedge lrclk_gen)
    begin
        $fwrite(fixed_output_fd,"%b\n",left_out_fixed);
        $fwrite(float_output_fd,"%b\n",left_out_float);
        $display("%d\n", progress);
    end
endmodule
