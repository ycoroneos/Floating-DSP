`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2017 02:23:46 AM
// Design Name: 
// Module Name: fir_fixedpoint
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


//https://www.xilinx.com/support/documentation/ip_documentation/fir_compiler_ds534.pdf
//page 17, figure 5

module fir_floating # (
parameter NTAPS=5,
parameter WIDTH = 32,
parameter TOP_BIT=31
)
(
input wire reset,
input wire lrclk,
input wire fastclk,
input wire [31:0] in,
output wire [31:0] out,
input wire [(NTAPS)*(WIDTH)-1:0] coeffs
    );
    //constants we need
    localparam NPIPES = 2*(NTAPS-1);
    localparam NDELAYS = NTAPS;
    localparam NADDS = NTAPS-1;
    localparam NMULS = NTAPS;

    localparam NMUL_REGS = NTAPS;
    localparam NADD_REGS = NTAPS-1;

    localparam startstate = 4'b0000;
    localparam waitstate  = 4'b0001;
    localparam waitresultsstate = 4'b0011;
    localparam donestate = 4'b0111;
    reg [3:0] count = 0;
    
    //declare the pipeline stages
    reg [31:0] pipes[NPIPES-1:0];
    reg [WIDTH-1:0] delays[NDELAYS-1:0];

    wire [31:0] mul_products[NMUL_REGS-1:0];
    wire [31:0] add_products[NADD_REGS-1:0];
    
    //declare the continuous stages
    wire [WIDTH-1:0] muls[NMULS-1:0];
    wire [WIDTH-1:0] adds[NADDS-1:0];

    wire pulse;
    reg [3:0] current_state = 0;
    
    //make the continuous assignments
    genvar j;
    //muls
    for (j=0; j<NMULS; j=j+1)
        begin
            // assign multiplication products to registers which contain the floating point products
            assign muls[j][WIDTH-1:0] = mul_products[j][WIDTH-1:0];
        end
    //adds
    for (j=0; j<NADDS; j=j+1)
        begin
            assign adds[j][WIDTH-1:0] = add_products[j][WIDTH-1:0];
        end

    // stuff for multiplier
    wire ina_ack[NMULS-1:0];
    wire inb_ack[NMULS-1:0];
    wire [NMULS-1:0] mult_out_stb;
    reg mult_reset = 1;

    // stuff for adder
    wire ina_add_ack[NMULS-1:0];
    wire inb_add_ack[NMULS-1:0];
    wire [NADDS-1:0] add_out_stb;
    reg add_reset = 1;


    // special case thing
    multiplier multiplier_1(
        .clk(fastclk),
        .rst(mult_reset),
        .input_a(   in[31:0]   ),
        .input_a_stb(1),
        .input_a_ack(ina_ack[0]),
        .input_b(   coeffs[0+:WIDTH]   ),
        .input_b_stb(1),
        .input_b_ack(inb_ack[0]),
        .output_z(   mul_products[0][WIDTH-1:0]   ),
        .output_z_stb(mult_out_stb[0]),
        .output_z_ack(0));

    for (j=1; j<NMULS; j=j+1)
        begin
            multiplier multiplier_j(
                .clk(fastclk),
                .rst(mult_reset),
                .input_a(   pipes[(2*j)-1][31:0]   ),
                .input_a_stb(1),
                .input_a_ack(ina_ack[j]),
                .input_b(  coeffs[j*WIDTH +: WIDTH]   ),
                .input_b_stb(1),
                .input_b_ack(inb_ack[j]),
                .output_z(  mul_products[j][WIDTH-1:0]   ),
                .output_z_stb(mult_out_stb[j]),
                .output_z_ack(0));
        end

    for (j=0; j<NADDS; j=j+1)
        begin
            adder adder_j(
                .clk(fastclk),
                .rst(add_reset),
                .input_a(    delays[j][WIDTH-1:0]    ),
                .input_a_stb(1),
                .input_a_ack(ina_add_ack[j]),
                .input_b(    muls[j+1][WIDTH-1:0]    ),
                .input_b_stb(1),
                .input_b_ack(inb_add_ack[j]),
                .output_z(    add_products[j][WIDTH-1:0]    ),
                .output_z_stb(add_out_stb[j]),
                .output_z_ack(0));
        end

    clock_sync syncer(
        .fastclk(fastclk), 
        .slowclk(lrclk), 
        .reset(reset),
        .ready(pulse));

    always @(posedge fastclk)
    begin
        if (reset == 1) begin
            current_state <= startstate;
            mult_reset <= 1;
            add_reset <= 1;
        end
        else begin
            case (current_state)
                startstate:
                    begin
                    mult_reset <= 1;
                    add_reset <= 1;
                    if (pulse == 1) begin
                        current_state <= waitstate;
                        count <= 4;
                    end
                    end
                waitstate:
                    begin
                    count <= count - 1;

                    // load values into the multiplier
                    if (count == 0) begin
                        mult_reset <= 0;
                        current_state <= waitresultsstate;
                    end
                    end
                waitresultsstate:
                    begin
                    if ((&mult_out_stb[NMULS-1:0]) == 1) 
                    begin
                        delays[0][WIDTH-1:0] <= muls[0][WIDTH-1:0];
                        add_reset <= 0;
                        current_state <= donestate;
                    end
                    end
                donestate:
                    begin
                    if ((&add_out_stb[NADDS-1:0]) == 1) 
                    begin
                        
                    //delays
                    for (i=1; i<NDELAYS; i=i+1)
                        begin
                            delays[i][WIDTH-1:0] <= adds[i-1][WIDTH-1:0];
                        end

                        current_state <= startstate;
                    end
                    end
            endcase
        end
    end

    assign out[31:0] = delays[NDELAYS-1][TOP_BIT -: 32];
    integer i;
    always @(negedge lrclk)
    begin
        if (reset)
        begin
            for (i=0; i<NDELAYS; i=i+1) delays[i] <= 0;
            for (i=0; i<NPIPES; i=i+1) pipes[i] <= 0;
        end
        else
        begin
            //pipeline
            for (i=0; i<NPIPES; i=i+1)
                begin
                    if (i==0)
                        begin
                            pipes[i][31:0] <= in[31:0];
                        end
                    else
                        begin
                            pipes[i][31:0] <= pipes[i-1][31:0];
                        end
                end
        end
    end
endmodule
