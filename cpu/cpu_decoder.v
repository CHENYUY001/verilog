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
    output          invalid,
    output          mov,
    output          sll,
    output          cmp,
    output          bbt
);
    reg flag;
    wire [4:0] rs,rt,rd;
    assign invalid = flag;
    assign rs = inst[25:21];
    assign rt = inst[20:16];
    assign rd = inst[15:11];
    reg [12:1]inst_flag;
    wire [16:0] inst_part;
    assign inst_part = {inst[31:26],inst[10:0]};
    always @ (*)
        begin
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
        if (inst_flag==12'b0) flag = 1;
        end
    assign wen = inst_flag[1]|inst_flag[2]|inst_flag[3]|inst_flag[4]|inst_flag[5]|inst_flag[7]|(inst_flag[9])|inst_flag[10]|inst_flag[11];
    assign waddr = ({5{inst_flag[1]|inst_flag[2]|inst_flag[3]|inst_flag[4]|inst_flag[5]|inst_flag[9]|inst_flag[10]|inst_flag[11]}}&rd)|({5{inst_flag[7]}} & rt);
    assign raddr1 = rs;
    assign raddr2 = rt;
    assign alu_card = ({5{inst_flag[1]}}&5'b00001) | ({5{inst_flag[2]}}&5'b00011) | ({5{inst_flag[3]}}&5'b01100) | ({5{inst_flag[4]}}&5'b01011)| ({5{inst_flag[5]}}&5'b01110) | 
                        ({5{inst_flag[9]|inst_flag[6]}}&5'b01000) | ({5{inst_flag[11]}}&5'b00111);
    assign mem_rd = inst_flag[7];  //读内存信号
    assign mem_wr = inst_flag[6];   //写内存信号
    assign jmp = inst_flag[8];       //判断是否为J指令
    assign mov = inst_flag[9];          //判断是否为MOV指令
    assign sll = inst_flag[10];         //判断是否为SLL指令
    assign cmp = inst_flag[11];         //判断是否为CMP指令
    assign bbt = inst_flag[12];         //判断是否为BBT指令
endmodule