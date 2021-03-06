`include "define.vh"

/* 
    id模块，对指令进行译码

    id模块与Regfile之间的连接：
        id模块只从Regfile模块读取数据，
        不会向Regfile模块写入数据
 */
module id (
    input   wire                rst,
    input   wire[`InstAddrBus]  pc_i,       //pc的值，也就是指令地址,在跳转的时候才用得上
    input   wire[`InstBus]      inst_i,     //指令内容

    //读取 Regfile 的信号
    output  reg                 re1_o,      //读使能 1
    output  reg                 re2_o,      //读使能 2
    output  reg[`RegAddrBus]    raddr1_o,
    output  reg[`RegAddrBus]    raddr2_o,
    input   wire[`RegDataBus]   rdata1_i,
    input   wire[`RegDataBus]   rdata2_i,     

    //写入 Regfile 的信号
    output  reg                 we_o,
    output  reg[`RegAddrBus]    waddr_o,


    //解决下一条指令的数据冲突，把执行阶段的结果直接交给译码阶段
    input   wire                ex_we_i,
    input   wire[`RegAddrBus]   ex_waddr_i,
    input   wire[`RegDataBus]   ex_wdata_i,

    //解决隔一条指令的数据冲突，把访存阶段的结果直接交给译码阶段
    input   wire                mem_we_i,
    input   wire[`RegAddrBus]   mem_waddr_i,
    input   wire[`RegDataBus]   mem_wdata_i,


    //送到执行阶段的信息
    output  reg[`AluOpBus]      aluop_o,
    output  reg[`AluSelBus]     alusel_o,
    output  reg[`RegDataBus]    data1_o,
    output  reg[`RegDataBus]    data2_o,

    //是否请求暂停流水线
    output  reg                 stallreq
    
);


//对指令的操作码、地址码进行分解
wire[5:0]   op     = inst_i[31:26];     // opcode
wire[4:0]   rs    = inst_i[25:21];      // rs
wire[4:0]   rt    = inst_i[20:16];      // rt
wire[4:0]   rd     = inst_i[15:11];     // rd
wire[4:0]   sa     = inst_i[10:6];      // 移位数
wire[5:0]   func   = inst_i[5:0];       // func


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
        we_o      = `Enable;            //默认写使能
        waddr_o   =  rd;                //默认目的寄存器地址
        instvalid = `True;
        re1_o     = `Disable;           //Regfile的读使能1
        re2_o     = `Disable;           //Regfile的读使能2
        raddr1_o  = rs;                 //默认读地址1
        raddr2_o  = rt;                 //默认读地址2
        imme      = `ZeroWord;
        case (op)
            `EXE_SPECIAL: begin         //特殊指令码
                case (sa)               //移位数
                    5'b00000: begin
                        case (func)     //根据功能码识别操作
                            `EXE_AND: begin                 //and
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_AND_OP;
                                alusel_o  = `EXE_RES_LOGIC;
                            end
                            `EXE_OR: begin                  //or
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_OR_OP;
                                alusel_o  = `EXE_RES_LOGIC;
                            end
                            `EXE_XOR: begin                 //xor
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_XOR_OP;
                                alusel_o  = `EXE_RES_LOGIC;
                            end
                            `EXE_NOR: begin                 //nor
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_NOR_OP;
                                alusel_o  = `EXE_RES_LOGIC;
                            end
                            `EXE_SLLV: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_SLL_OP;
                                alusel_o  = `EXE_RES_SHIFT;
                            end
                            `EXE_SRLV: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_SRL_OP;
                                alusel_o  = `EXE_RES_SHIFT;
                            end
                            `EXE_SRAV: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_SRA_OP;
                                alusel_o  = `EXE_RES_SHIFT;
                            end
                            /* sync指令用于保证载入、存储操作的顺序，
                                对于OpenMIPS而言，
                                是严格依照指令顺序运行的，载入、存储操作也是依照顺序进行的，
                                所以能够将sync指令当作nop指令处理，在这里将其归纳为空指令。 */
                            `EXE_SYNC: begin                //sync指令
                                instvalid = `True;
                                we_o      = `Disable;
                                re1_o     = `Disable;
                                re2_o     = `Enable;        //为什么要一个读端口？？？
                                aluop_o   = `EXE_NOP_OP;
                                alusel_o  = `EXE_RES_NOP;
                            end

                            `EXE_MOVN: begin                //movn: rs -> rd（rt不为0）
                                instvalid = `True;
                                re1_o     = `Enable;
                                re2_o     = `Enable;                //读使能，地址 rt
                                aluop_o   = `EXE_MOVN_OP;
                                alusel_o  = `EXE_RES_MOVE;
                                if (data2_o == `ZeroWord) begin     //data_2 就是 rt 的值
                                    we_o  = `Disable;
                                end else begin
                                    we_o  = `Enable;
                                end
                            end

                            `EXE_MOVZ: begin                //movz: rs -> rd（rt为0）
                                instvalid = `True;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_MOVZ_OP;
                                alusel_o  = `EXE_RES_MOVE;
                                if (data2_o == `ZeroWord) begin
                                    we_o  = `Enable;
                                end else begin
                                    we_o = `Disable;
                                end
                            end

                            `EXE_MFHI: begin                //mfhi: hi -> rd
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Disable;
                                re2_o     = `Disable;
                                aluop_o   = `EXE_MFHI_OP;
                                alusel_o  = `EXE_RES_MOVE;
                            end

                            `EXE_MFLO: begin                //mflo: lo -> rd
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Disable;
                                re2_o     = `Disable;
                                aluop_o   = `EXE_MFLO_OP;
                                alusel_o  = `EXE_RES_MOVE;
                            end

                            `EXE_MTHI: begin                //mthi：rs -> hi
                                instvalid = `True;
                                we_o      = `Disable;
                                re1_o     = `Enable;
                                re2_o     = `Disable;
                                aluop_o   = `EXE_MTHI_OP;
                                //alusel_o  = `EXE_RES_MOVE; 特殊，不属于移动指令
                            end

                            `EXE_MTLO: begin                //mflo: rs -> lo
                                instvalid = `True;
                                we_o      = `Disable;
                                re1_o     = `Enable;
                                re2_o     = `Disable;
                                aluop_o   = `EXE_MTLO_OP;
                                //alusel_o  = `EXE_RES_MOVE;  特殊，不属于移动指令
                            end

                            `EXE_ADD: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_ADD_OP;
                                alusel_o  = `EXE_RES_ARITHMETIC;
                            end

                            `EXE_ADDU: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_ADDU_OP;
                                alusel_o  = `EXE_RES_ARITHMETIC;
                            end

                            `EXE_SUB: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_SUB_OP;
                                alusel_o  = `EXE_RES_ARITHMETIC;
                            end

                            `EXE_SUBU: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_SUBU_OP;
                                alusel_o  = `EXE_RES_ARITHMETIC;
                            end

                            `EXE_SLT: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_SLT_OP;
                                alusel_o  = `EXE_RES_ARITHMETIC;
                            end

                            `EXE_SLTU: begin
                                instvalid = `True;
                                we_o      = `Enable;
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_SLTU_OP;
                                alusel_o  = `EXE_RES_ARITHMETIC;
                            end

                            `EXE_MULT: begin                
                                instvalid = `True;
                                we_o      = `Disable;       //写入 hilo，不写 rd
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_MULT_OP;
                                // alusel_o  = `EXE_RES_MUL;   //乘法不属于简单算术类型
                            end

                            `EXE_MULTU: begin                
                                instvalid = `True;
                                we_o      = `Disable;       //写入 hilo，不写 rd
                                re1_o     = `Enable;
                                re2_o     = `Enable;
                                aluop_o   = `EXE_MULTU_OP;
                                // alusel_o  = `EXE_RES_MUL;   //乘法不属于简单算术类型
                            end

                            default: begin
                            end
                            endcase
                    end

                    default: begin
                    end
                endcase
            end

            `EXE_SPECIAL_2: begin
                case (func)
                    `EXE_CLZ: begin     //rs左边 0 的个数，赋值给 rd
                        instvalid = `True;
                        we_o      = `Enable;
                        re1_o     = `Enable;
                        re2_o     = `Disable;
                        aluop_o   = `EXE_CLZ_OP;
                        alusel_o  = `EXE_RES_ARITHMETIC;
                    end
                    `EXE_CLO: begin     //rs左边 1 的个数，赋值给 rd
                        instvalid = `True;
                        we_o      = `Enable;
                        re1_o     = `Enable;
                        re2_o     = `Disable;
                        aluop_o   = `EXE_CLO_OP;
                        alusel_o  = `EXE_RES_ARITHMETIC;
                    end
                    `EXE_MUL: begin
                        instvalid = `True;
                        we_o      = `Enable;
                        re1_o     = `Enable;
                        re2_o     = `Enable;
                        aluop_o   = `EXE_MUL_OP;
                        alusel_o  = `EXE_RES_MUL;
                    end
                endcase
            end
                    
            `EXE_ORI: begin                  //根据op的值判断是否是ori指令
                instvalid = `True;           //ori是有效指令
                aluop_o   = `EXE_OR_OP;      //告诉ALU是或运算
                alusel_o  = `EXE_RES_LOGIC;  //告诉ALU运算类型是逻辑运算
                re1_o     = `Enable;         //从读端口1读出源操作数
                re2_o     = `Disable;        //读端口2用不到
                imme      = {16'h0, inst_i[15:0]};    //对立即数进行扩展
                we_o      = `Enable;         //将结果写入目的寄存器，写使能
                waddr_o   = rt;             //结果写入的寄存器地址
            end

            `EXE_ANDI: begin                  //根据op的值判断是否是andi指令
                instvalid = `True;           //andi是有效指令
                aluop_o   = `EXE_AND_OP;      //告诉ALU是与运算
                alusel_o  = `EXE_RES_LOGIC;  //告诉ALU运算类型是逻辑运算
                re1_o     = `Enable;         //从读端口1读出源操作数
                re2_o     = `Disable;        //读端口2用不到
                raddr1_o  = rs;             //读端口1的源操作数地址
                imme      = {16'h0, inst_i[15:0]};    //对立即数进行扩展
                we_o      = `Enable;         //将结果写入目的寄存器，写使能
                waddr_o   = rt;             //结果写入的寄存器地址
            end

            `EXE_XORI: begin                  //根据op的值判断是否是xori指令
                instvalid = `True;           //xori是有效指令
                aluop_o   = `EXE_XOR_OP;      //告诉ALU是异或运算
                alusel_o  = `EXE_RES_LOGIC;  //告诉ALU运算类型是逻辑运算
                re1_o     = `Enable;         //从读端口1读出源操作数
                re2_o     = `Disable;        //读端口2用不到
                raddr1_o  = rs;             //读端口1的源操作数地址
                imme      = {16'h0, inst_i[15:0]};    //对立即数进行扩展
                we_o      = `Enable;         //将结果写入目的寄存器，写使能
                waddr_o   = rt;             //结果写入的寄存器地址
            end

            /* lui指令：
                把立即数放入 rt 寄存器的高 16 位
             */
            `EXE_LUI: begin                  //根据op的值判断是否是lui指令
                instvalid = `True;           //lui是有效指令
                aluop_o   = `EXE_OR_OP;      
                alusel_o  = `EXE_RES_LOGIC;  
                re1_o     = `Enable;         
                re2_o     = `Disable;        
                raddr1_o  = rs;             
                imme      = {inst_i[15:0], 16'h0};    //这里是左移
                we_o      = `Enable;         
                waddr_o   = rt;             
            end

            `EXE_ADDI: begin
                instvalid   = `True;
                we_o        = `Enable;
                re1_o       = `Enable;
                re2_o       = `Disable;
                aluop_o     = `EXE_ADD_OP;
                alusel_o    = `EXE_RES_ARITHMETIC;
                imme        = { { 16{inst_i[15]} }, inst_i[15:0] };
                waddr_o     = rt;
            end

            `EXE_ADDIU: begin
                instvalid   = `True;
                we_o        = `Enable;
                re1_o       = `Enable;
                re2_o       = `Disable;
                aluop_o     = `EXE_ADDU_OP;
                alusel_o    = `EXE_RES_ARITHMETIC;
                imme        = { { 16{inst_i[15]} }, inst_i[15:0] };
                waddr_o     = rt;
            end

            `EXE_SLTI: begin
                instvalid   = `True;
                we_o        = `Enable;
                re1_o       = `Enable;
                re2_o       = `Disable;
                aluop_o     = `EXE_SLT_OP;
                alusel_o    = `EXE_RES_ARITHMETIC;
                imme        = { { 16{inst_i[15]} }, inst_i[15:0] };
                waddr_o     = rt;
            end

            `EXE_SLTIU: begin
                instvalid   = `True;
                we_o        = `Enable;
                re1_o       = `Enable;
                re2_o       = `Disable;
                aluop_o     = `EXE_SLTU_OP;
                alusel_o    = `EXE_RES_ARITHMETIC;
                imme        = { { 16{inst_i[15]} }, inst_i[15:0] };
                waddr_o     = rt;
            end

            /* pref指令用于缓存预取，
                OpenMIPS没有实现缓存，
                所以也能够将pref指令当作nop指令处理，
                此处也将其归纳为空指令。 
            */
            `EXE_PREF: begin                  //根据op的值判断是否是prep指令
                instvalid = `True;           
                aluop_o   = `EXE_NOP_OP;      
                alusel_o  = `EXE_RES_NOP;
                we_o      = `Disable;  
                re1_o     = `Disable;         
                re2_o     = `Disable;        
                raddr1_o  = rs;                        
            end

            default: begin
            end    
        endcase

        //带立即数的移位指令，不需要读rs
        if (inst_i[31:21] == 11'b00000000000) begin
            case(func)
                `EXE_SLL: begin                     //sll
                    instvalid   = `True;
                    aluop_o     = `EXE_SLL_OP;
                    alusel_o    = `EXE_RES_SHIFT;
                    we_o        = `Enable;
                    re1_o       = `Disable;
                    re2_o       = `Enable;
                    imme[4:0]   = sa;
                end

                `EXE_SRL: begin                     //srl
                    instvalid   = `True;
                    aluop_o     = `EXE_SRL_OP;
                    alusel_o    = `EXE_RES_SHIFT;
                    we_o        = `Enable;
                    re1_o       = `Disable;
                    re2_o       = `Enable;
                    imme[4:0]   = sa;
                end

                `EXE_SRA: begin                     //sra
                    instvalid   = `True;
                    aluop_o     = `EXE_SRA_OP;
                    alusel_o    = `EXE_RES_SHIFT;
                    we_o        = `Enable;
                    re1_o       = `Disable;
                    re2_o       = `Enable;
                    imme[4:0]   = sa;
                end

                default begin
                end

            endcase
        end
    end
end


/* 
    第二段：确定进行运算的源操作数1 
    如果Regfile的读端口1有效，就把读出来的数作为操作数，
    否则把立即数作为操作数1。

 */
always @(*) begin
    if(rst) begin
        data1_o = `ZeroWord;
    end else if( re1_o && ex_we_i 
                && (raddr1_o == ex_waddr_i)       //这条指令要用到上一条指令的运算结果
                ) begin     
        data1_o = ex_wdata_i;
    end else if( re1_o && mem_we_i
                && (raddr1_o == mem_waddr_i)      //这条指令要用到上上条指令的运算结果
                ) begin   
        data1_o = mem_wdata_i;
    end else if(re1_o) begin
        data1_o = rdata1_i;    
    end else if(~re1_o) begin
        data1_o = imme;
    end else begin
        data1_o = `ZeroWord;
    end
end

/* 
    第三段：确定进行运算的源操作数2
    如果Regfile的读端口2有效，就把读出来的数作为操作数2，
    否则把立即数作为操作数2.

 */
always @(*) begin
    if(rst) begin
        data2_o = `ZeroWord;
    end else if( re2_o && ex_we_i 
                && (raddr2_o == ex_waddr_i)       //这条指令要用到上一条指令的运算结果
                ) begin     
        data2_o = ex_wdata_i;
    end else if( re2_o && mem_we_i
                && (raddr2_o == mem_waddr_i)      //这条指令要用到上上条指令的运算结果
                ) begin   
        data2_o = mem_wdata_i;
    end else if(re2_o) begin
        data2_o = rdata2_i;    
    end else if(~re2_o) begin
        data2_o = imme;
    end else begin
        data2_o = `ZeroWord;
    end
end

endmodule //id