`include "define.vh"

/* 
    id模块，对指令进行译码
    TMD直接组合逻辑，连clk都不要了。

    id模块与Regfile之间的连接：
        id模块只从Regfile模块读取数据，
        不会向Regfile模块写入数据
 */
module id (
    input   wire                rst,
    input   wire[`InstAddrBus]  pc_i,       //指令地址,暂时没用上啊
    input   wire[`InstBus]      inst_i,     //指令内容

    //读取Regfile
    output  reg                 re1_o,
    output  reg                 re2_o,
    output  reg[`RegAddrBus]    raddr1_o,
    output  reg[`RegAddrBus]    raddr2_o,
    input   wire[`RegDataBus]   rdata1_i,
    input   wire[`RegDataBus]   rdata2_i,     


    //解决下一条指令的数据冲突，把执行阶段的结果直接交给译码阶段
    input   wire                ex_we_i,
    input   wire[`RegAddrBus]   ex_waddr_i,
    input   wire[`RegDataBus]   ex_wdata_i,

    //解决隔一条指令的数据冲突，把访存阶段的结果直接交给译码阶段
    input   wire                mem_we_i,
    input   wire[`RegAddrBus]   mem_waddr_i,
    input   wire[`RegDataBus]   mem_wdata_i,

    
    //写入Regfile
    //现在结果还没出来，所以写结果不是id模块的事，把信号传给后面
    output  reg                 we_o,
    output  reg[`RegAddrBus]    waddr_o,

    //送到执行阶段的信息
    output  reg[`AluOpBus]      aluop_o,
    output  reg[`AluSelBus]     alusel_o,
    output  reg[`RegDataBus]    data1_o,
    output  reg[`RegDataBus]    data2_o
    
);


//对指令的操作码、地址码进行分解
wire[5:0]   op  = inst_i[31:26];        //操作码
wire[4:0]   op1 = inst_i[25:21];        //操作数 1 的地址
wire[4:0]   op2 = inst_i[20:16];        //结果写入的地址
wire[15:0]  op3 = inst_i[15:0];         //立即数的地址


//保存扩展后的立即数
reg[`RegDataBus]    imme;

//指示指令是否有效
reg instvalid;


/* 
    第一段：对指令进行译码
 */
always @(*) begin
    if(rst) begin
        aluop_o   = `EXE_NOP_OP;
        alusel_o  = `EXE_RES_NOP;
        we_o      = `Disable;
        waddr_o   = `RegAddr_0;
        instvalid = `False;
        re1_o     = `Disable;
        re2_o     = `Disable;
        raddr1_o  = `RegAddr_0;
        raddr2_o  = `RegAddr_0;
        imme      = `ZeroWord;
    end else begin
        aluop_o   = `EXE_NOP_OP;
        alusel_o  = `EXE_RES_NOP;
        we_o      = `Enable;           //写使能???
        waddr_o   =  inst_i[15:11];    //结果地址????
        instvalid = `True;
        re1_o     = `Disable;          //Regfile的读使能1
        re2_o     = `Disable;          //Regfile的读使能2
        raddr1_o  = op1;               //读地址1
        raddr2_o  = op2;               //读地址2
        imme      = `ZeroWord;
        case (op)
            `EXE_ORI: begin                  //根据op的值判断是否是ori指令
                instvalid = `True;           //ori是有效指令
                aluop_o   = `EXE_OR_OP;      //告诉ALU运算类型是逻辑运算
                alusel_o  = `EXE_RES_LOGIC;  //告诉ALU具体运算是逻辑或运算
                re1_o     = `Enable;         //从读端口1读出源操作数
                re2_o     = `Disable;        //读端口2用不到
                raddr1_o  = op1;             //读端口1的源操作数地址
                imme      = {16'h0, op3};    //对立即数进行扩展
                we_o      = `Enable;         //将结果写入目的寄存器，写使能
                waddr_o   = op2;             //结果写入的寄存器地址
            end
            default: begin
            end    
        endcase
    end
end


/* 
    第二段：确定进行运算的源操作数1 
    如果Regfile的读端口1有效，就把读出来的数作为操作数，
    否则把立即数作为操作数1。
    在ori指令里re1_o是有效的，因此把从Regfile读出来的数作为源操作数1.
 */
always @(*) begin
    if(rst) begin
        data1_o = `ZeroWord;
    end else if( re1_o && ex_we_i 
                && raddr1_o == ex_waddr_i       //这条指令要用到上一条指令的运算结果
                ) begin     
        data1_o = ex_wdata_i;
    end else if( re1_o && mem_we_i
                && raddr1_o == mem_waddr_i      //这条指令要用到上上条指令的运算结果
                ) begin   
        data1_o = mem_wdata_i;
    end else if(re1_o) begin
        data1_o = rdata1_i;    
    end else if(~re1_o) begin
        data1_o = `ZeroWord;
    end else begin
        data1_o = `ZeroWord;
    end
end

/* 
    第三段：确定进行运算的源操作数2
    如果Regfile的读端口2有效，就把读出来的数作为操作数2，
    否则把立即数作为操作数2.
    在ori指令里re2_o是无效的，因此把立即数作为操作数2.
 */
always @(*) begin
    if(rst) begin
        data2_o = `ZeroWord;
    end else if( re2_o && ex_we_i 
                && raddr2_o == ex_waddr_i       //这条指令要用到上一条指令的运算结果
                ) begin     
        data2_o = ex_wdata_i;
    end else if( re2_o && mem_waddr_i
                && raddr2_o == mem_waddr_i      //这条指令要用到上上条指令的运算结果
                ) begin    
        data2_o = mem_wdata_i;
    end else if(re2_o) begin
        data2_o = rdata2_i;            
    end else if(~re2_o) begin
        data2_o = `ZeroWord;
    end else begin
        data2_o = `ZeroWord;
    end
end

endmodule //id