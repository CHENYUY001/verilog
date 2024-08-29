`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/29 18:20:56
// Design Name: 
// Module Name: bram_top_tb
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


module bram_top_tb;

    // Signal declarations
    reg         clk;        // Clock signal
    reg  [15:0] ram_addr;   // Address signal
    reg  [31:0] ram_wdata;  // Write data signal
    reg         ram_wen;    // Write enable signal
    wire [31:0] ram_rdata;  // Read data signal

    // Instantiate the bram_top module
    bram_top uut (
        .clk(clk),
        .ram_addr(ram_addr),
        .ram_wdata(ram_wdata),
        .ram_wen(ram_wen),
        .ram_rdata(ram_rdata)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock period of 10 ns
    end

    // Test sequence
    initial begin
        // Initialize inputs
        ram_wen = 0;
        ram_addr = 0;
        ram_wdata = 0;

        // Wait for the clock to stabilize
        #10;

        // Test write operation to address 0
        ram_wen = 1;
        ram_addr = 16'h0000;
        ram_wdata = 32'hDEADBEEF;
        #10;  // Wait for the write to take effect

        // Test write operation to address 1
        ram_wen = 1;
        ram_addr = 16'h0001;
        ram_wdata = 32'hCAFEBABE;
        #10;  // Wait for the write to take effect

        // Disable write enable to perform read operations
        ram_wen = 0;

        // Test read operation from address 0
        ram_addr = 16'h0000;
        #10;  // Wait for the read to take effect
        $display("Read data from address 0: %h (Expected: DEADBEEF)", ram_rdata);

        // Test read operation from address 1
        ram_addr = 16'h0001;
        #10;  // Wait for the read to take effect
        $display("Read data from address 1: %h (Expected: CAFEBABE)", ram_rdata);

        // Test read operation from address 2 (which has not been written to)
        ram_addr = 16'h0002;
        #10;  // Wait for the read to take effect
        $display("Read data from address 2: %h (Expected: 00000000)", ram_rdata);

        // End the simulation
        #10;
        $finish;
    end

endmodule
