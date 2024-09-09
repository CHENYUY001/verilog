`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/09 14:42:14
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


module cpu(
    input           clk,                // 时钟信号
    input           resetn,             // 低有效复位信号

    output          inst_sram_en,       // 指令存储器读使能
    output [31:0]   inst_sram_addr,     // 指令存储器读地址
    input [31:0]    inst_sram_rdata,    // 指令存储器读出的数据

    output          data_sram_en,       // 数据存储器端口读/写使能
    output [3:0]    data_sram_wen,      // 数据存储器写使能      
    output [31:0]   data_sram_addr,     // 数据存储器读/写地址
    output [31:0]   data_sram_wdata,    // 写入数据存储器的数据
    input [31:0]    data_sram_rdata,    // 数据存储器读出的数据

    // 供自动测试环境进行CPU正确性检查
    output [31:0]   debug_wb_pc,        // 当前正在执行指令的PC
    output          debug_wb_rf_wen,    // 当前通用寄存器组的写使能信号
    output [4:0]    debug_wb_rf_wnum,   // 当前通用寄存器组写回的寄存器编号
    output [31:0]   debug_wb_rf_wdata   // 当前指令需要写回的数据
);

    // 定义 CPU 内部信号
    reg [31:0] pc;  // 程序计数器
    reg [31:0] next_pc;
    reg [31:0] regfile [31:0];  // 寄存器堆
    reg [31:0] alu_out;  // ALU 输出
    reg [31:0] write_data;  // 写入寄存器堆的数据
    reg [31:0] instruction;  // 当前指令
    reg [31:0] mem_rdata;  // 从数据存储器读出的数据

    // 寄存器控制信号
    reg [4:0] rs, rt, rd;
    reg [15:0] imm;
    reg [5:0] funct;
    reg [5:0] opcode;
    reg [31:0] sign_ext_imm;
    reg [31:0] branch_target;
    
    // 控制信号
    reg alu_src, reg_dst, mem_to_reg, reg_write, mem_read, mem_write, branch, jump;
    reg [4:0] alu_control;

    // 初始化寄存器和信号
    integer i;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            pc <= 32'h00000000;
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= 32'b0;
            end
        end else begin
            pc <= next_pc;
            if (reg_write && debug_wb_rf_wnum != 5'b0) begin
                regfile[debug_wb_rf_wnum] <= write_data;
            end
        end
    end

    // 指令存储器访问
    assign inst_sram_en = 1'b1;
    assign inst_sram_addr = pc;
    always @(posedge clk) begin
        instruction <= inst_sram_rdata;  // 取指令
    end

    // 从指令中提取字段
    always @(*) begin
        opcode = instruction[31:26];
        rs = instruction[25:21];
        rt = instruction[20:16];
        rd = instruction[15:11];
        imm = instruction[15:0];
        funct = instruction[5:0];
        sign_ext_imm = {{16{imm[15]}}, imm};  // 符号扩展
        branch_target = (sign_ext_imm << 2) + pc + 4;
    end

    // ALU 和控制单元
    always @(*) begin
        case (opcode)
            6'b000000: begin  // R型指令
                case (funct)
                    6'b100000: begin  // ADD
                        alu_control = 5'b00001;
                        alu_src = 0;
                        reg_dst = 1;
                        reg_write = 1;
                    end
                    6'b100010: begin  // SUB
                        alu_control = 5'b00011;
                        alu_src = 0;
                        reg_dst = 1;
                        reg_write = 1;
                    end
                    6'b100100: begin  // AND
                        alu_control = 5'b01100;
                        alu_src = 0;
                        reg_dst = 1;
                        reg_write = 1;
                    end
                    6'b100101: begin  // OR
                        alu_control = 4'b01011;
                        alu_src = 0;
                        reg_dst = 1;
                        reg_write = 1;
                    end
                    6'b100110: begin  // XOR
                        alu_control = 5'b01110;
                        alu_src = 0;
                        reg_dst = 1;
                        reg_write = 1;
                    end
                    default: begin
                        alu_control = 5'b11111;  // 无效操作
                    end
                endcase
            end
            6'b100011: begin  // LW 指令
                alu_control = 5'b00001;  // ALU 做加法计算地址
                alu_src = 1;  // ALU 第二个操作数是立即数（偏移量）
                reg_dst = 0;  // 写回寄存器为rt
                reg_write = 1;  // 使能写回寄存器
                mem_read = 1;  // 读取数据存储器
            end 
            6'b101011: begin  // SW
                alu_control = 5'b00001;
                alu_src = 1;
                mem_write = 1;
                reg_write = 0;
            end
            6'b000100: begin  // BEQ
                alu_control = 5'b00011;  // SUB
                alu_src = 0;
                branch = 1;
            end
            6'b000010: begin  // J
                jump = 1;
            end
            default: begin
                alu_control = 5'b11111;  // 无效操作
            end
        endcase
    end

    // ALU 计算
    always @(*) begin
        case (alu_control)
            5'b00001: alu_out = regfile[rs] + (alu_src ? sign_ext_imm : regfile[rt]);  // 加法
            5'b00011: alu_out = regfile[rs] - regfile[rt];  // 减法
            5'b01100: alu_out = regfile[rs] & regfile[rt];  // AND
            5'b01011: alu_out = regfile[rs] | regfile[rt];  // OR
            5'b01110: alu_out = regfile[rs] ^ regfile[rt];  // XOR
            default: alu_out = 32'b0;  // 默认值
        endcase
    end

    // 数据存储器访问
    assign data_sram_en = mem_read | mem_write;
    assign data_sram_wen = mem_write ? 5'b11111 : 5'b00000;
    assign data_sram_addr = alu_out;
    assign data_sram_wdata = regfile[rt];
    always @(posedge clk) begin
        if (mem_read) begin
            mem_rdata <= data_sram_rdata;  // 从数据存储器读取的数据
        end  // 从存储器读取的数据
    end

    // 写回阶段
    always @(*) begin
        if (mem_to_reg)
            write_data = mem_rdata;  // 来自内存
        else
            write_data = alu_out;  // 来自 ALU
    end

    // 跳转和分支
    always @(*) begin
        if (jump)
            next_pc = {pc[31:28], instruction[25:0], 2'b00};
        else if (branch && alu_out == 32'b0)
            next_pc = branch_target;
        else
            next_pc = pc + 4;
    end

    // 调试信号
    assign debug_wb_pc = pc;
    assign debug_wb_rf_wen = reg_write;
    assign debug_wb_rf_wnum = reg_dst ? rd : rt;
    assign debug_wb_rf_wdata = write_data;

endmodule
