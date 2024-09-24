`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 19:04:15
// Design Name: 
// Module Name: adder_32bit
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


module adder_32bit (
    input  [31:0] A,
    input  [31:0] B,
    input         Cin,
    output [31:0] F,
    output        Cout
);

    assign {Cout, F} = A + B + Cin;

endmodule