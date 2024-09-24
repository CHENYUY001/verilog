`timescale 1ns / 1ps

module regfile_tb;

    // Declare signals
    reg          clk;         // Clock signal
    reg   [4:0]  raddr1;      // Read address 1
    wire  [31:0] rdata1;      // Read data 1
    reg   [4:0]  raddr2;      // Read address 2
    wire  [31:0] rdata2;      // Read data 2
    reg          we;          // Write enable
    reg   [4:0]  waddr;       // Write address
    reg   [31:0] wdata;       // Write data

    // Instantiate the regfile module
    regfile uut (
        .clk(clk),
        .raddr1(raddr1),
        .rdata1(rdata1),
        .raddr2(raddr2),
        .rdata2(rdata2),
        .we(we),
        .waddr(waddr),
        .wdata(wdata)
    );

    // Generate a clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle clock every 5ns
    end

    // Test sequence
    initial begin
        // Initialize signals
        we = 1; raddr1 = 5'b0; raddr2 = 5'b0; waddr = 5'b0; wdata = 32'b0;

        // Wait for a few clock cycles to ensure initialization
        #15;

        // Write data to register 1
        we = 1; waddr = 5'd1; wdata = 32'hA5A5A5A5;
        #10; // Wait for one clock cycle

        // Write data to register 2
        we = 1; waddr = 5'd2; wdata = 32'h5A5A5A5A;
        #10; // Wait for one clock cycle

        // Disable write enable after writing
        we = 0;

        // Read data from register 1
        raddr1 = 5'd1;
        #10; // Wait for one clock cycle to allow read data to stabilize
        $display("Read data1 from register 1: %h (Expected: A5A5A5A5)", rdata1);

        // Read data from register 2
        raddr2 = 5'd2;
        #10; // Wait for one clock cycle to allow read data to stabilize
        $display("Read data2 from register 2: %h (Expected: 5A5A5A5A)", rdata2);

        // Read data from register 0 (should be 0 as it's never written)
        raddr1 = 5'd0;
        #10; // Wait for one clock cycle to allow read data to stabilize
        $display("Read data1 from register 0: %h (Expected: 00000000)", rdata1);

        // End simulation
        #10;
        $finish;
    end

endmodule
