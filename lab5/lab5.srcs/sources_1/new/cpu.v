`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/24 19:30:30
// Design Name: 
// Module Name: cpu
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
`define OR      5'b01011
`define AND     5'b01100    
`define SOR     5'b01101
`define NOR     5'b01110
`define ANDNOT  5'b01111
`define ZERO    5'b10000

module cpu(
    input           clk,               
    input           resetn,            

    output          inst_sram_en,       
    output[31:0]    inst_sram_addr,     
    input[31:0]     inst_sram_rdata, 

    output          data_sram_en,      
    output[3:0]     data_sram_wen,    
    output[31:0]    data_sram_addr,   
    output[31:0]    data_sram_wdata,  
    input[31:0]     data_sram_rdata,  

    output[31:0]    debug_wb_pc,       
    output          debug_wb_rf_wen,
    output[4:0]     debug_wb_rf_wnum,
    output[31:0]    debug_wb_rf_wdata 
);

    reg[3:1] T;
    always @(posedge clk ) begin 
            if (!resetn) begin
                T <= 3'b100;
            end else begin
                T <= {T[2:1], T[3]};
            end
    end
    assign inst_sram_en = T[3];

    (*mark_debug = "true"*)wire[31:0] inst;
    assign inst = inst_sram_rdata;
    wire[25:0] jmp_part = inst[25:0];
    wire[15:0] bbt_part = inst[15:0];
    wire[1:0] sel;
    wire[31:0] pc;

    PC_select PC_select(
        .clk(clk),
        .T(T[1]),
        .resetn(resetn),
        .sel(sel),
        .jmp_part(jmp_part),
        .bbt_part(bbt_part),
        .pc_val(pc)
    );

    assign inst_sram_addr = pc;
    reg[31:0] pc_keep;
    always @(posedge clk) begin
        if (T[3])
            begin 
            pc_keep = pc;
            end
        if (!resetn) pc_keep = 0;
    end
    assign debug_wb_pc = pc_keep;

    wire wen;
    wire[4:0] waddr;
    wire[4:0] raddr1;
    wire[4:0] raddr2;
    wire[4:0] alu_card;
    wire mem_rd;
    wire mem_wr;
    wire jmp;
    wire mov;
    wire sll;
    wire cmp;
    wire bbt;
    (*mark_debug = "true"*)wire reg_wen;
    assign data_sram_wen = mem_wr;
    assign data_sram_en = mem_wr | mem_rd;
    wire[31:0] rs_data;
    wire[31:0] rt_data;   
    wire[31:0] wb_data;
    assign sel = (jmp)?2'b01:(bbt&rs_data[inst[20:16]])?2'b10:2'b00;
    assign reg_wen = (wen&mov)? (!rt_data):wen;

    cpu_decoder cpu_decoder(
        .inst(inst),
        .resetn(resetn),
        .wen(wen),
        .waddr(waddr),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .alu_card(alu_card),
        .mem_rd(mem_rd),
        .mem_wr(mem_wr),
        .jmp(jmp),
        .mov(mov),
        .sll(sll),
        .cmp(cmp),
        .bbt(bbt)
    );

    Reg_ Reg_(
        .clk(clk),
        .resetn(resetn),
        .T3(T[3]),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .we(reg_wen),
        .waddr(waddr),
        .wdata(wb_data),
        .rdata1(rs_data),
        .rdata2(rt_data)
    );

    wire[31:0] alu_res;
    wire zero;
    wire Cout;
    alu_ alu_(
        .A(rs_data),
        .B(rt_data),
        .Cin(1'b0),
        .Card(alu_card),
        .F(alu_res),
        .Cout(Cout),
        .Zero(zero)
    );

    wire[31:0] cmp_res;
    wire[31:0] sll_res;
    assign sll_res = rt_data<<inst[10:6];
    assign cmp_res[0] = (rs_data == rt_data)?1'b1:1'b0;
    assign cmp_res[1] = ($signed(rs_data)-$signed(rt_data) < 0)?1'b1:1'b0;
    assign cmp_res[3] = ($signed(rs_data)-$signed(rt_data) <= 0)?1'b1:1'b0;
    assign cmp_res[2] = (rs_data < rt_data)?1'b1:1'b0;
    assign cmp_res[4] = (rs_data <= rt_data)?1'b1:1'b0;
    assign cmp_res[9:5] = ~cmp_res[4:0];
    assign cmp_res[31:10] = 0;

    assign wb_data = cmp ? cmp_res:
    sll ? sll_res:
    (mov & zero) ? rs_data:
    mem_rd?data_sram_rdata:
    alu_res;

    assign data_sram_addr = rs_data+{{16{inst[15]}},inst[15:0]};
    assign data_sram_wdata = alu_res;
    assign debug_wb_rf_wdata = wb_data;
    assign debug_wb_rf_wen = ((waddr!=0)&reg_wen) & T[3];
    assign debug_wb_rf_wnum = waddr;
endmodule

module alu_ (
    input  [31:0]   A,
    input  [31:0]   B,
    input           Cin,
    input  [4:0]    Card,

    output [31:0]   F,
    output          Cout,
    output          Zero
);

    wire [31:0]    add1_result;
    wire [31:0]    add2_result;
    wire [31:0]    sub1_result;
    wire [31:0]    sub2_result;
    wire [31:0]    sub3_result;
    wire [31:0]    sub4_result;
    wire [31:0]    and_result;
    wire [31:0]    or_result;
    wire [31:0]    sor_result;
    wire [31:0]    nor_result;
    wire [31:0]    andnot_result;
    wire flag1, flag2;

    assign {flag1, add1_result}  = A + B;
    assign {flag2, add2_result}  = A + B + Cin;

    assign sub1_result  = A - B;
    assign sub2_result  = A - B - Cin;
    assign sub3_result  = B - A;
    assign sub4_result  = B - A - Cin;

    assign and_result  = A & B;
    assign or_result  = A | B;
    assign sor_result  = ~(A ^ B);
    assign nor_result  = A ^ B;
    assign andnot_result  = ~(A & B);

    assign F =   ({32{Card == `ADD_1}}  & add1_result )  |
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

    assign Cout = ({32{Card == `ADD_1}}  & flag1) |
                  ({32{Card == `ADD_2}}  & flag2);
    assign Zero = (F == 32'b0);

endmodule

module cpu_decoder (
    input[31:0]     inst,
    input           resetn,
    output          wen,
    output[4:0]     waddr,
    output[4:0]     raddr1,
    output[4:0]     raddr2,
    output[4:0]     alu_card,
    output          mem_rd,
    output          mem_wr,
    output          jmp,
    output          mov,
    output          sll,
    output          cmp,
    output          bbt
);

    reg flag;
    wire [4:0] rs, rt, rd;
    assign rs = inst[25:21];
    assign rt = inst[20:16];
    assign rd = inst[15:11];
    reg [12:1]inst_flag;
    wire [16:0] inst_part;
    assign inst_part = {inst[31:26],inst[10:0]};

    always @(*) begin
        if (!resetn) inst_flag = 0;
        flag = 0;
        casez(inst_part)
            17'b00000000000100000: inst_flag = 12'b000000000001;
            17'b00000000000100010: inst_flag = 12'b000000000010;
            17'b00000000000100100: inst_flag = 12'b000000000100;
            17'b00000000000100101: inst_flag = 12'b000000001000;
            17'b00000000000100110: inst_flag = 12'b000000010000;
            17'b101011???????????: inst_flag = 12'b000000100000;
            17'b100011???????????: inst_flag = 12'b000001000000;
            17'b000010???????????: inst_flag = 12'b000010000000;
            17'b00000000000001010: inst_flag = 12'b000100000000;
            17'b11111000000000000: inst_flag = 12'b010000000000;
            17'b111111???????????: inst_flag = 12'b100000000000;
            17'b000000?????000000: inst_flag = (inst[25:21]==5'b0)?(12'b001000000000):12'b0;
            default:  flag = 1;
        endcase
        if (inst_flag == 12'b0) flag = 1;
    end

    assign wen = inst_flag[1] | inst_flag[2] | inst_flag[3] | inst_flag[4] | inst_flag[5] | inst_flag[7] | inst_flag[9] | inst_flag[10] | inst_flag[11];
    assign waddr = ({5{inst_flag[1] | inst_flag[2] | inst_flag[3] | inst_flag[4] | inst_flag[5] | inst_flag[9] | inst_flag[10] | inst_flag[11]}} & rd) |
                   ({5{inst_flag[7]}} & rt);
    assign raddr1 = rs;
    assign raddr2 = rt;
    assign alu_card = ({5{inst_flag[1]}} & 5'b00001) | ({5{inst_flag[2]}} & 5'b00011) | 
                      ({5{inst_flag[3]}} & 5'b01100) | ({5{inst_flag[4]}} & 5'b01011) | 
                      ({5{inst_flag[5]}} & 5'b01110) | ({5{inst_flag[9] | inst_flag[6]}} & 5'b01000) | 
                      ({5{inst_flag[11]}} & 5'b00111);

    assign mem_rd = inst_flag[7];  
    assign mem_wr = inst_flag[6];   
    assign jmp = inst_flag[8];       
    assign mov = inst_flag[9];          
    assign sll = inst_flag[10];         
    assign cmp = inst_flag[11];         
    assign bbt = inst_flag[12];         
endmodule

module PC_select (
    input clk,
    input T,
    input resetn,
    input [1:0] sel,
    input[25:0] jmp_part,
    input[15:0] bbt_part,
    output [31:0] pc_val
);

    (*mark_debug = "true"*)reg [31:0] pc = 0;
    assign pc_val = pc;
    wire[31:0] npc = pc + 4;
    wire[31:0] jmp_pc = {npc[31:28], jmp_part[25:0], 2'b00};
    wire[31:0] bbt_pc = ({{16{bbt_part[15]}},bbt_part} << 2) + npc;
    wire[31:0] pc_res = (sel == 2'b10) ? bbt_pc : (sel == 2'b01) ? jmp_pc : npc;

    always @(posedge clk) begin             
        if (resetn == 0) 
            pc <= 32'b0;
        else if (T) 
            pc <= pc_res;
    end
endmodule

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
            Reg[waddr] <= wdata;
    end 

    assign rdata1 = Reg[raddr1]; 
    assign rdata2 = Reg[raddr2];
endmodule 

