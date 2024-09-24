`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 19:18:20
// Design Name: 
// Module Name: alu_tb
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


`timescale 1ns / 1ps  // Time unit and precision

`define ADD     5'b00001  // A + B
`define ADDC    5'b00010  // A + B + Cin
`define SUB     5'b00011  // A - B
`define SUBC    5'b00100  // A - B - Cin
`define SUBR    5'b00101  // B - A
`define SUBRC   5'b00110  // B - A - Cin
`define PASS_A  5'b00111  // F = A
`define PASS_B  5'b01000  // F = B
`define NOT_A   5'b01001  // F = ~A
`define NOT_B   5'b01010  // F = ~B
`define OR_OP   5'b01011  // F = A | B
`define AND_OP  5'b01100  // F = A & B
`define XNOR_OP 5'b01101  // F = A ~^ B (XNOR)
`define XOR_OP  5'b01110  // F = A ^ B
`define NAND_OP 5'b01111  // F = ~(A & B)
`define ZERO_OP 5'b10000  // F = 0


module alu_tb;  // Testbench module

    // ALU Inputs
    reg [31:0] A;    // 32-bit input A
    reg [31:0] B;    // 32-bit input B
    reg Cin;         // Carry-in input
    reg [4:0] Card;  // 5-bit operation code

    // ALU Outputs
    wire [31:0] F;   // 32-bit output result
    wire Cout;       // Carry-out output
    wire Zero;       // Zero flag output

    // Instantiate the ALU module (Unit Under Test - UUT)
    alu uut (
        .A(A), 
        .B(B), 
        .Cin(Cin), 
        .Card(Card), 
        .F(F), 
        .Cout(Cout), 
        .Zero(Zero)
    );

    // Generate test cases
    initial begin
        // Monitor simulation time, inputs, and outputs
        $monitor("Time = %0t | A = %h | B = %h | Cin = %b | Card = %b | F = %h | Cout = %b | Zero = %b", 
                  $time, A, B, Cin, Card, F, Cout, Zero);

        // Initialize inputs for all operations
        A = 32'h00000001;  
        B = 32'h00000001;  
        Cin = 0;
        
        // Test case 1: Addition (A + B)
        Card = `ADD;  
        #10;

        // Test case 2: Addition with carry (A + B + Cin)
        Cin = 1;  // Set carry-in to 1
        Card = `ADDC; 
        #10;

        // Test case 3: Subtraction (A - B)
        A = 32'h00000002;  
        B = 32'h00000001;
        Cin = 0;
        Card = `SUB; 
        #10;

        // Test case 4: Subtraction with carry (A - B - Cin)
        Cin = 1;
        Card = `SUBC;
        #10;

        // Test case 5: Reverse Subtraction (B - A)
        A = 32'h00000001;  
        B = 32'h00000002;
        Cin = 0;
        Card = `SUBR; 
        #10;

        // Test case 6: Reverse Subtraction with carry (B - A - Cin)
        Cin = 1;
        Card = `SUBRC;
        #10;

        // Test case 7: Pass A (F = A)
        A = 32'hFFFFFFFF;  // A = all 1s
        Card = `PASS_A; 
        #10;

        // Test case 8: Pass B (F = B)
        B = 32'h0000000F;  // B = 15
        Card = `PASS_B;
        #10;

        // Test case 9: NOT A (F = ~A)
        A = 32'hAAAAAAAA;  // A = alternating 1s and 0s
        Card = `NOT_A;
        #10;

        // Test case 10: NOT B (F = ~B)
        B = 32'h55555555;  // B = alternating 0s and 1s
        Card = `NOT_B;
        #10;

        // Test case 11: OR Operation (F = A | B)
        A = 32'hF0F0F0F0;  
        B = 32'h0F0F0F0F;  
        Card = `OR_OP; 
        #10;

        // Test case 12: AND Operation (F = A & B)
        A = 32'hFF00FF00;  
        B = 32'h00FF00FF;  
        Card = `AND_OP; 
        #10;

        // Test case 13: XNOR Operation (F = A ~^ B)
        A = 32'hAAAA5555;  
        B = 32'h5555AAAA;  
        Card = `XNOR_OP; 
        #10;

        // Test case 14: XOR Operation (F = A ^ B)
        A = 32'h12345678;  
        B = 32'h87654321;  
        Card = `XOR_OP; 
        #10;

        // Test case 15: NAND Operation (F = ~(A & B))
        A = 32'hFFFFFFFF;  
        B = 32'h00000000;  
        Card = `NAND_OP; 
        #10;

        // Test case 16: Zero Operation (F = 0)
        Card = `ZERO_OP;
        #10;

        // End simulation
        $finish;
    end

endmodule

