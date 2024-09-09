`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 23:10:56
// Design Name: 
// Module Name: inst_decoder
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

module inst_decoder(
    input [31:0] inst,
    output wen,
    output [4:0] waddr,
    output rden1,
    output [4:0] raddr1,
    output rden2,
    output [4:0] raddr2,
    output alu_en,
    output [4:0] alu_card,
    output mem_rd,
    output mem_wr,
    output jmp,
    output invalid
);

    // 提取指令字段
    wire [5:0] opcode = inst[31:26];  // 操作码
    wire [4:0] rs = inst[25:21];      // 源寄存器1
    wire [4:0] rt = inst[20:16];      // 源寄存器2 / 目标寄存器
    wire [4:0] rd = inst[15:11];      // 目标寄存器
    wire [5:0] funct = inst[5:0];     // 功能码

    // 操作码定义
    localparam ADD_OPCODE = 6'b000000, ADD_FUNCT = 6'b100000;
    localparam SUB_FUNCT = 6'b100010;
    localparam AND_FUNCT = 6'b100100;
    localparam OR_FUNCT = 6'b100101;
    localparam XOR_FUNCT = 6'b100110;
    localparam LW_OPCODE = 6'b100011;
    localparam SW_OPCODE = 6'b101011;
    localparam J_OPCODE = 6'b000010;

    // ALU操作码定义（根据实验2定义）
    localparam ALU_ADD = 5'b00001;
    localparam ALU_SUB = 5'b00011;
    localparam ALU_AND = 5'b01100;
    localparam ALU_OR  = 5'b01011;
    localparam ALU_XOR = 5'b01110;
    // 组合逻辑生成控制信号
    assign wen = (opcode == ADD_OPCODE && 
                 (funct == ADD_FUNCT || funct == SUB_FUNCT || funct == AND_FUNCT || funct == OR_FUNCT || funct == XOR_FUNCT)) || 
                 (opcode == LW_OPCODE);

    assign waddr = (opcode == ADD_OPCODE) ? rd : 
                   (opcode == LW_OPCODE) ? rt : 
                   5'b00000;  // 默认值

    assign rden1 = (opcode == ADD_OPCODE || opcode == LW_OPCODE || opcode == SW_OPCODE);
    assign raddr1 = rs;

    assign rden2 = (opcode == ADD_OPCODE || opcode == SW_OPCODE);
    assign raddr2 = (opcode == ADD_OPCODE) ? rt : 
                    (opcode == SW_OPCODE) ? rt : 
                    5'b00000;  // 默认值

    assign alu_en = (opcode == ADD_OPCODE);
    assign alu_card = (funct == ADD_FUNCT) ? ALU_ADD :
                      (funct == SUB_FUNCT) ? ALU_SUB :
                      (funct == AND_FUNCT) ? ALU_AND :
                      (funct == OR_FUNCT)  ? ALU_OR :
                      (funct == XOR_FUNCT) ? ALU_XOR :
                      5'b00000;  // 默认值

    assign mem_rd = (opcode == LW_OPCODE);
    assign mem_wr = (opcode == SW_OPCODE);
    assign jmp = (opcode == J_OPCODE);
    assign invalid = !(opcode == ADD_OPCODE && 
                      (funct == ADD_FUNCT || funct == SUB_FUNCT || funct == AND_FUNCT || funct == OR_FUNCT || funct == XOR_FUNCT)) &&
                      (opcode != LW_OPCODE && opcode != SW_OPCODE && opcode != J_OPCODE);

endmodule