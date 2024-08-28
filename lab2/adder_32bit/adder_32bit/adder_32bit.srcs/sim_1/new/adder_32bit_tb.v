`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 19:08:56
// Design Name: 
// Module Name: adder_32bit_tb
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


`timescale  1ns / 1ps

module adder_32bit_tb;


// adder_32bit Inputs
reg   [31:0]  A                            = 0 ;
reg   [31:0]  B                            = 0 ;
reg   Cin                                  = 0 ;

// adder_32bit Outputs
wire  [31:0]  F                            ;    
wire  Cout                                 ;



adder_32bit  u_adder_32bit (
    .A                       ( A     [31:0] ),
    .B                       ( B     [31:0] ),
    .Cin                     ( Cin          ),

    .F                       ( F     [31:0] ),
    .Cout                    ( Cout         )
);

initial
begin
    $monitor("Time = %0t | A = %h | B = %h | Cin = %b | F = %h | Cout = %b", $time, A, B, Cin, F, Cout);

    A = 32'h00000000;
    B = 32'h00000000;
    Cin = 0;
    #10;

    A = 32'h00000001;
    B = 32'h00000001;
    Cin = 0;
    #10;

    A = 32'h00000001;
    B = 32'h00000001;
    Cin = 1; 
    #10;

    A = 32'hFFFFFFFF;
    B = 32'h00000001;
    Cin = 0;  
    #10; 

    A = 32'hFFFFFFFF; 
    B = 32'hFFFFFFFF;  
    Cin = 0;        
    #10; 

    A = 32'hFFFFFFFF;  
    B = 32'hFFFFFFFF; 
    Cin = 1;    
    #10; 


    $finish;
end

endmodule