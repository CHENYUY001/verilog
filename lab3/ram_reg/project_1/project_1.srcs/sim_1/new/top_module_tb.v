`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 14:32:15
// Design Name: 
// Module Name: top_module_tb
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



module top_module_tb;

  // Declare testbench signals for the inputs and outputs of the DUT
  reg clk;
  reg rst;
  reg [4:0] reg_raddr1;
  reg [4:0] reg_raddr2;
  reg reg_we;
  reg [4:0] reg_waddr;
  reg [31:0] reg_wdata;
  reg ram_we;
  reg [15:0] ram_addr;
  reg [31:0] ram_wdata;
  wire [31:0] reg_rdata1;
  wire [31:0] reg_rdata2;
  wire [31:0] ram_rdata;

  // Instantiate the DUT (Device Under Test)
  top_module dut (
    .clk(clk),
    .rst(rst),
    .reg_raddr1(reg_raddr1),
    .reg_rdata1(reg_rdata1),
    .reg_raddr2(reg_raddr2),
    .reg_rdata2(reg_rdata2),
    .reg_we(reg_we),
    .reg_waddr(reg_waddr),
    .reg_wdata(reg_wdata),
    .ram_we(ram_we),
    .ram_addr(ram_addr),
    .ram_rdata(ram_rdata)
  );

  // Clock generation: 10ns period (100 MHz)
  always #5 clk = ~clk;

  // Initial block for generating reset and test sequences
  initial begin
    // Initialize all signals
    clk = 0;
    rst = 1;
    reg_raddr1 = 0;
    reg_raddr2 = 0;
    reg_we = 0;
    reg_waddr = 0;
    reg_wdata = 0;
    ram_we = 0;
    ram_addr = 0;
    ram_wdata = 0;

    // Apply reset for 20ns
    #20 rst = 0;

    // Wait for a few clock cycles after reset is deasserted
    #10;

    // Test case 1: Write to a register and verify read
    reg_we = 1;
    reg_waddr = 5'b00001; // Write to register 1
    reg_wdata = 32'hA5A5A5A5; // Test data
    #10 reg_we = 0;

    // Read from register 1
    reg_raddr1 = 5'b00001;
    #10;
    
    // Test case 2: Write data to RAM and read back
    ram_we = 1;
    ram_addr = 16'h0001;
    ram_wdata = 32'hDEADBEEF; // Test data
    #10 ram_we = 0;
    
    // Read from RAM
    #10;

    // End of simulation
    #100;
    $finish;
  end

  // Display monitor to check output
  initial begin
    $monitor("Time: %0t | reg_rdata1: %h | ram_rdata: %h", $time, reg_rdata1, ram_rdata);
  end

endmodule

