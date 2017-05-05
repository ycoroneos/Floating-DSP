`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2017 08:13:43 PM
// Design Name: 
// Module Name: memory
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


module memory #(
NTAPS=5,
WIDTH=32
)
(
output wire [((NTAPS)*(WIDTH))-1:0] out
);
//reg [(NTAPS*WIDTH)-1 : 0] looktable [0:0];
//assign out[(NTAPS*WIDTH)-1 : 0] = looktable[0][(NTAPS*WIDTH)-1 : 0];
reg [WIDTH-1:0] looktable [(NTAPS-1) : 0];

genvar i;
for (i=0; i<NTAPS; i=i+1)
    begin
        assign out[((WIDTH)*i) +: (WIDTH)] = looktable[i][(WIDTH-1) : 0];
    end
    
initial begin
   $readmemh("coeff.list", looktable);
end
endmodule
