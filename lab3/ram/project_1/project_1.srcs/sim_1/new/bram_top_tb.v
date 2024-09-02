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

  // Testbench signals for regfile
    reg         clk;
    reg  [4:0]  raddr1;
    wire [31:0] rdata1;
    reg  [4:0]  raddr2;
    wire [31:0] rdata2;
    reg         we;
    reg  [4:0]  waddr;
    reg  [31:0] wdata;
    
    // Testbench signals for bram_top
    reg  [15:0] ram_addr;
    reg  [31:0] ram_wdata;
    reg         ram_wen;
    wire [31:0] ram_rdata;
    
    // Instantiate the regfile module
    regfile regfile_inst (
        .clk(clk),
        .raddr1(raddr1),
        .rdata1(rdata1),
        .raddr2(raddr2),
        .rdata2(rdata2),
        .we(we),
        .waddr(waddr),
        .wdata(wdata)
    );

    // Instantiate the bram_top module
    bram_top bram_top_inst (
        .clk(clk),
        .ram_addr(ram_addr),
        .ram_wdata(ram_wdata),
        .ram_wen(ram_wen),
        .ram_rdata(ram_rdata)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signals
        we = 0;
        raddr1 = 5'd0;
        raddr2 = 5'd0;
        waddr = 5'd0;
        wdata = 32'd0;
        ram_addr = 16'd0;
        ram_wdata = 32'd0;
        ram_wen = 0;
        
        // Reset and initialize
        #10;

        // Step 1: Write data to RAM
        ram_addr = 16'd0;
        ram_wdata = 32'hDEADBEEF;
        ram_wen = 1;
        #10;
        ram_wen = 0;
        
        // Step 2: Read data from RAM to register file
        // Wait for the RAM write to complete
        #10;
        raddr1 = 5'd0;  // Assume we want to load RAM[0] into registers[0]
        ram_addr = 16'd0;
        #10; // Wait for data to be ready
        
        // Load data from RAM to regfile
        waddr = 5'd0; // Destination register address
        wdata = ram_rdata; // Load data from RAM output
        we = 1; // Enable write
        #10;
        we = 0; // Disable write after loading

        // Step 3: Write data from register file back to RAM
        #10;
        raddr1 = 5'd0; // Read data from register 0
        ram_addr = 16'd1; // Destination address in RAM
        ram_wdata = rdata1; // Data to write back to RAM
        ram_wen = 1;
        #10;
        ram_wen = 0;

        // Step 4: Verify the data
        // Read back from RAM to verify
        #10;
        ram_addr = 16'd1; // Address to read back
        #10;

        // Check if the data in RAM[1] matches register data
        if (ram_rdata == 32'hDEADBEEF) begin
            $display("Test Passed: Data transferred correctly.");
        end else begin
            $display("Test Failed: Data mismatch.");
        end

        // Finish simulation
        #10;
        $finish;
    end

endmodule
