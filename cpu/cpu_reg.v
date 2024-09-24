module Reg_(
    input clk,
    input T3,
    input resetn,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input we,
    input [4:0] waddr,
    input [31:0] wdata,
    output [31:0] rdata1,
    output [31:0] rdata2
);
    integer i;
    reg [31:0] Reg[31:0]; 
    always @(posedge clk) begin
        if (!resetn)
            for (i = 0; i < 32; i = i + 1)
                Reg[i] <= 32'b0;
        else if (T3 & we)
            begin
            Reg[waddr] <= wdata;
            end     
        end 
    assign rdata1 = Reg[raddr1]; 
    assign rdata2 = Reg[raddr2];
endmodule 
