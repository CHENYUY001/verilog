`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/29 20:34:14
// Design Name: 
// Module Name: regfile
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


module regfile (
    input          clk,
    input   [4:0]  raddr1,
    output [31:0]  rdata1,
    input   [4:0]  raddr2,
    output [31:0]  rdata2,
    input          we,
    input   [4:0]  waddr,
    input   [31:0] wdata
);
    reg [31:0] registers [31:0];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end
    // Read ports
    assign rdata1 = registers[raddr1];
    assign rdata2 = registers[raddr2];

    // Write port
    always @(posedge clk) begin
        if (we)
            registers[waddr] <= wdata;
    end
endmodule
