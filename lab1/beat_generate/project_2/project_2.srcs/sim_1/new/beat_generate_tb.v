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


`timescale 1ns / 1ps  // ����ʱ�䵥λ��ʱ�侫��

module beat_generate_tb;  // ����ģ������

    // �����ź�
    reg clk;              // ʱ���ź�
    reg rst;              // ��λ�ź�
    wire [3:0] T;         // 4λ����ź�

    // ʵ����������ģ��
    beat_generate uut (
        .clk(clk), 
        .rst(rst), 
        .T(T)
    );

    // ����ʱ���źţ�����Ϊ10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // ÿ5ns��תһ��clk�ź�
    end

    // ���Լ���
    initial begin
        // ��ط���ʱ�䡢���������ź�
        $monitor("Time = %0t | clk = %b | rst = %b | T = %b", $time, clk, rst, T);

        // ��ʼ����λ�ź�
        rst = 1;         // ���λ
        #20;             // �ȴ�20ns
        rst = 0;         // �ͷŸ�λ
        #100;            // �ȴ�100ns���۲�����仯

        // ���¸�λ
        rst = 1;         // �ٴμ��λ
        #10;             // �ȴ�10ns
        rst = 0;         // �ͷŸ�λ
        #50;             // �ȴ�50ns���۲�����仯

        // ��ɲ��ԣ���������
        $finish;
    end

endmodule
