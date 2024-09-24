module PC_select (
    input clk,
    input T,
    input resetn,
    input [1:0] sel,    //根据sel选择正确的PC
    input[25:0] jmp_part,
    input[15:0] bbt_part,
    output [31:0] pc_val
);
    (*mark_debug = "true"*)reg [31:0] pc = 0;
    assign pc_val = pc;
    wire[31:0] npc = pc + 4;
    wire[31:0] jmp_pc = {npc[31:28], jmp_part[25:0], 2'b00};
    wire[31:0] bbt_pc = ({{16{bbt_part[15]}},bbt_part}<<2) + npc;
    wire[31:0] pc_res = (sel == 2'b10) ? bbt_pc 
                        : (sel == 2'b01) ? jmp_pc
                        : npc;

    always @(posedge clk)
        begin             
            if (resetn == 0) 
                pc <= 32'b0;
            else if (T)begin 
                pc <= pc_res;
            end
        end
endmodule
