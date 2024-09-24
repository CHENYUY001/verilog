`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 15:46:47
// Design Name: 
// Module Name: mux_2_1_tb
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


module mux_2_1_tb;  // ����ģ�����ƣ�һ���� DUT ���� + "_tb"

    // �����ź�
    reg [1:0] d0;       // 2λ���������ź� d0
    reg [1:0] d1;       // 2λ���������ź� d1
    reg select;         // ѡ���ź�
    wire [1:0] out;     // 2λ��������ź� out

    // ʵ����������ģ��
    mux_2_1 uut (
        .d0(d0), 
        .d1(d1), 
        .select(select), 
        .out(out)
    );

    // ��ʼ�������ź�
    initial begin
        // ��ط���ʱ�䡢���������ź�
        $monitor("Time = %0t | d0 = %b | d1 = %b | select = %b | out = %b", $time, d0, d1, select, out);
        
        // ���ó�ʼ����ֵ
        d0 = 2'b00; d1 = 2'b11; select = 0;
        #10;  // �ӳ�10��ʱ�䵥λ

        d0 = 2'b01; d1 = 2'b10; select = 0;
        #10;

        d0 = 2'b01; d1 = 2'b10; select = 1;
        #10;

        d0 = 2'b10; d1 = 2'b01; select = 0;
        #10;

        d0 = 2'b10; d1 = 2'b01; select = 1;
        #10;

        // ��ɲ��Ժ󣬽�������
        $finish;
    end

endmodule
