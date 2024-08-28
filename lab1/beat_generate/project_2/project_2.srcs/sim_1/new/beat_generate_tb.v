`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 15:53:21
// Design Name: 
// Module Name: beat_generate_tb
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


`timescale 1ns / 1ps  // 设置时间单位和时间精度

module beat_generate_tb;  // 测试模块名称

    // 声明信号
    reg clk;              // 时钟信号
    reg rst;              // 复位信号
    wire [3:0] T;         // 4位输出信号

    // 实例化被测试模块
    beat_generate uut (
        .clk(clk), 
        .rst(rst), 
        .T(T)
    );

    // 生成时钟信号，周期为10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 每5ns反转一次clk信号
    end

    // 测试激励
    initial begin
        // 监控仿真时间、输入和输出信号
        $monitor("Time = %0t | clk = %b | rst = %b | T = %b", $time, clk, rst, T);

        // 初始化复位信号
        rst = 1;         // 激活复位
        #20;             // 等待20ns
        rst = 0;         // 释放复位
        #100;            // 等待100ns，观察输出变化

        // 重新复位
        rst = 1;         // 再次激活复位
        #10;             // 等待10ns
        rst = 0;         // 释放复位
        #50;             // 等待50ns，观察输出变化

        // 完成测试，结束仿真
        $finish;
    end

endmodule
