`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 15:53:01
// Design Name: 
// Module Name: beat_generate
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


module beat_generate(
    input clk,
    input rst,
    output reg [3:0] T
    );
    
always @(posedge clk or posedge rst) begin
    if (rst)
        T <= 4'b1000;
    else
        T <= {T[0],T[3:1]};
end
    
endmodule
