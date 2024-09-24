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
    (*mark_debug = "true"*)output          debug_wb_rf_wen,
    (*mark_debug = "true"*)output[4:0]     debug_wb_rf_wnum,
    (*mark_debug = "true"*)output[31:0]    debug_wb_rf_wdata 
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
    wire[31:0] last_pc;
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

    //***ָ�����벿��***//

    wire wen;
    wire[4:0] waddr;
    wire[4:0] raddr1;
    wire[4:0] raddr2;
    wire[4:0] alu_card;
    wire mem_rd;
    wire mem_wr;
    wire jmp;
    wire invalid;
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
        .invalid(invalid),
        .mov(mov),
        .sll(sll),
        .cmp(cmp),
        .bbt(bbt)
    );

    //***�Ĵ����Ѳ���***//

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

    //***ALU����***//
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

    //**�Ƚ�������λ������**//
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

    //**ѡ��д�ؼĴ�������**//

    assign wb_data = cmp ? cmp_res:
    sll ? sll_res:
    (mov & zero) ? rs_data:
    mem_rd?data_sram_rdata:
    alu_res;

    //** ����ȷ���洢���Ľӿ�**//
    assign data_sram_addr = rs_data+{{16{inst[15]}},inst[15:0]};
    assign data_sram_wdata = alu_res;
    assign debug_wb_rf_wdata = wb_data;
    assign debug_wb_rf_wen = ((waddr!=0)&reg_wen) & T[3];
    assign debug_wb_rf_wnum = waddr;
endmodule


