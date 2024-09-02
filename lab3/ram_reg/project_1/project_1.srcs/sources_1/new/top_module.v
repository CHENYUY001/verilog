`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 14:23:25
// Design Name: 
// Module Name: top_module
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


module top_module (
    input          clk,
    input          rst,
    input   [4:0]  reg_raddr1,  // Register read address 1
    output  [31:0] reg_rdata1,  // Register read data 1
    input   [4:0]  reg_raddr2,  // Register read address 2
    output  [31:0] reg_rdata2,  // Register read data 2
    input          reg_we,      // Register write enable
    input   [4:0]  reg_waddr,   // Register write address
    input   [31:0] reg_wdata,   // Register write data
    input          ram_we,      // RAM write enable
    input   [15:0] ram_addr,    // RAM address
    output  [31:0] ram_rdata    // RAM read data
);
    
    // Declare ram_wdata as reg
    reg [31:0] ram_wdata;

    // Instantiate the register file
    regfile u_regfile (
        .clk   (clk),
        .raddr1(reg_raddr1),
        .rdata1(reg_rdata1),
        .raddr2(reg_raddr2),
        .rdata2(reg_rdata2),
        .we    (reg_we),
        .waddr (reg_waddr),
        .wdata (reg_wdata)
    );

    // Instantiate the RAM
    bram_top u_bram_top (
        .clk      (clk),
        .ram_addr (ram_addr),
        .ram_wdata(ram_wdata),
        .ram_wen  (ram_we),
        .ram_rdata(ram_rdata)
    );

    // Example of procedural assignment
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ram_wdata <= 0;  // Reset logic
        end else begin
            if (ram_we) begin
                // Write to RAM from register
                ram_wdata <= reg_rdata1;  // Example: Write reg_rdata1 to RAM
            end
        end
    end

endmodule
