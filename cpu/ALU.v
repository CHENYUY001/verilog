`define ADD_1   5'b00001
`define ADD_2   5'b00010
`define SUB_1   5'b00011
`define SUB_2   5'b00100
`define SUB_3   5'b00101
`define SUB_4   5'b00110
`define EQA     5'b00111
`define EQB     5'b01000
`define NOTA    5'b01001
`define NOTB    5'b01010
`define OR     5'b01011
`define AND      5'b01100    
`define SOR    5'b01101
`define NOR     5'b01110
`define ANDNOT  5'b01111
`define ZERO    5'b10000
module alu_ (
    input  [31:0]   A   ,
    input  [31:0]   B   ,
    input           Cin ,
    input  [4 :0]   Card,

    output [31:0]   F   ,
    output          Cout,
    output          Zero
);
    
    wire [31:0]    add1_result;
    wire [31:0]    add2_result;

    wire [31:0]    sub2_result;
    wire [31:0]    sub3_result;
    wire [31:0]    sub4_result;
    wire [31:0]    sub1_result; 

    wire [31:0]    and_result;
    wire [31:0]    or_result;
    wire [31:0]    sor_result;
    wire [31:0]    nor_result;
    wire [31:0]    andnot_result;
    wire flag1,flag2;
    assign {flag1, add1_result}  = A+B;
    assign {flag2, add2_result}  = A+B+Cin;

    assign sub1_result  = A-B;
    assign sub2_result  = A-B-Cin;
    assign sub3_result  = B-A;
    assign sub4_result  = B-A-Cin;

    assign and_result  = A & B;
    assign or_result  = A | B;
    assign sor_result  = ~(A ^ B);
    assign nor_result  = A ^ B;
    assign andnot_result  = ~(A & B);
    assign  F   =   ({32{Card == `ADD_1}}  & add1_result )  |
                    ({32{Card == `ADD_2}}  & add2_result)  |
                    ({32{Card == `SUB_1}}  & sub1_result)  |
                    ({32{Card == `SUB_2}} & sub2_result) |
                    ({32{Card == `SUB_3}}  & sub3_result)  |
                    ({32{Card == `SUB_4}} & sub4_result) |
                    ({32{Card == `EQA}}  & A)  |
                    ({32{Card == `EQB}} & B) |
                    ({32{Card == `NOTA}}  & ~A)  |
                    ({32{Card == `NOTB}} & ~B) |
                    ({32{Card == `AND}}  & and_result)  |
                    ({32{Card == `OR}} & or_result) |
                    ({32{Card == `SOR}} & sor_result) |
                    ({32{Card == `NOR}} & nor_result) |  
                    ({32{Card == `ANDNOT}} & andnot_result);         

    assign  Cout =  ({32{Card == `ADD_1}}  & flag1 )  |
                    ({32{Card == `ADD_2}}  & flag2);
    assign  Zero =  (F==32'b0);

endmodule


