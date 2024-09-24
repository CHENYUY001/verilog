`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 19:18:05
// Design Name: 
// Module Name: alu
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

module alu (
    input  [31:0] A,
    input  [31:0] B,
    input         Cin,
    input  [4:0]  Card,

    output [31:0] F,
    output        Cout,
    output        Zero
);

    wire [31:0] add_result;
    wire [31:0] addc_result;
    wire [31:0] sub_result;
    wire [31:0] subc_result;
    wire [31:0] subr_result;
    wire [31:0] subrc_result;
    wire [31:0] not_a_result;
    wire [31:0] not_b_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] xnor_result;
    wire [31:0] xor_result;
    wire [31:0] nand_result;
    wire [31:0] zero_result;
    wire [31:0] pass_a_result;
    wire [31:0] pass_b_result;

    // Implement operations
    assign add_result  = A + B;
    assign addc_result = A + B + Cin;
    assign sub_result  = A - B;
    assign subc_result = A - B - Cin;
    assign subr_result = B - A;
    assign subrc_result = B - A - Cin;
    assign not_a_result = ~A;
    assign not_b_result = ~B;
    assign or_result = A | B;
    assign and_result = A & B;
    assign xnor_result = ~(A ^ B);
    assign xor_result = A ^ B;
    assign nand_result = ~(A & B);
    assign zero_result = 32'b0;
    assign pass_a_result = A;
    assign pass_b_result = B;

    // Select the appropriate result based on the operation code
    assign F = ({32{Card == `ADD}}  & add_result)  |
               ({32{Card == `ADDC}} & addc_result) |
               ({32{Card == `SUB}}  & sub_result)  |
               ({32{Card == `SUBC}} & subc_result) |
               ({32{Card == `SUBR}} & subr_result) |
               ({32{Card == `SUBRC}} & subrc_result) |
               ({32{Card == `PASS_A}} & pass_a_result) |
               ({32{Card == `PASS_B}} & pass_b_result) |
               ({32{Card == `NOT_A}} & not_a_result) |
               ({32{Card == `NOT_B}} & not_b_result) |
               ({32{Card == `OR_OP}} & or_result) |
               ({32{Card == `AND_OP}} & and_result) |
               ({32{Card == `XNOR_OP}} & xnor_result) |
               ({32{Card == `XOR_OP}} & xor_result) |
               ({32{Card == `NAND_OP}} & nand_result) |
               ({32{Card == `ZERO_OP}} & zero_result);

    // Output signals for Cout and Zero
    assign Cout = (Card == `ADD || Card == `ADDC) ? add_result[31] :
                  (Card == `SUB || Card == `SUBC) ? sub_result[31] :
                  (Card == `SUBR || Card == `SUBRC) ? subr_result[31] : 1'b0;
    
    assign Zero = (F == 32'b0) ? 1'b1 : 1'b0;

endmodule

