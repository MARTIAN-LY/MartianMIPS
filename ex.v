`include "define.vh"


/* 
    执行模块
 */
module ex (
    input   wire    rst,

    //接受到的信息
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegDataBus]   data1_i,
    input   wire[`RegDataBus]   data2_i,
    input   wire[`RegAddrBus]   waddr_i,
    input   wire                we_i,

    //因为读写hilo模块而新增的端口
    input   wire[`RegDataBus]   hi_i,
    input   wire[`RegDataBus]   lo_i,
    input   wire                mem_whilo_i,    //上条指令访存部分是否要读写 hilo 模块
    input   wire[`RegDataBus]   mem_hi_i,
    input   wire[`RegDataBus]   mem_lo_i,
    input   wire                wb_whilo_i,     //上上条指令回写部分是否要读写 hilo 模块
    input   wire[`RegDataBus]   wb_hi_i,
    input   wire[`RegDataBus]   wb_lo_i,
    output  reg                 whilo_o,        //这条指令要不要读写 hilo 模块
    output  reg[`RegDataBus]    hi_o,
    output  reg[`RegDataBus]    lo_o,

    //执行的结果
    output  reg                 we_o,
    output  reg[`RegAddrBus]    waddr_o,
    output  reg[`RegDataBus]    result_o,

    output  reg                 stallreq        //是否请求暂停流水线
);

//暂存运算结果
reg[`RegDataBus]     logic_out;
reg[`RegDataBus]     shift_out;
reg[`RegDataBus]     move_out;
reg[`RegDataBus]     arith_out;
reg[`DoubleWordBus]  mul_out;

reg[`RegDataBus]     HI;     //保存 HI 寄存器的最新值
reg[`RegDataBus]     LO;     //保存 LO 寄存器的最新值


wire data1_eq_data2;                //第一个操作数是否等于第二个操作数
wire data1_lt_data2;                //第一个操作数是否小于第二个操作数
wire over_sum;                      //加法是否溢出
wire[`RegDataBus]       data2_mux;  //保存操作数 2 的补码
wire[`RegDataBus]       data1_not;  //保存操作数 1 取反后的值
wire[`RegDataBus]       result_sum; //保存加法结果
wire[`RegDataBus]       op1_mult;   //乘法的被乘数
wire[`RegDataBus]       op2_mult;   //乘法的 乘数
wire[`DoubleWordBus]    hilo_temp;  //临时保存乘法结果，64位


/* 如果是减法、有符号数的比较，那么第二个操作数是 -data2_i  
    有符号数的比较是通过两个数相减得到的，
    而减法又是转换为加法实现的，
    so，要算 -data2_i
*/
assign data2_mux = ( (aluop_i == `EXE_SUB_OP) 
                        || (aluop_i == `EXE_SUBU_OP)
                        || (aluop_i == `EXE_SLT_OP) 
                        ? (~data2_i + 1) : data2_i );

assign result_sum = data1_i + data2_mux;    //加法结果

// 加法是否溢出: 正正得负， 负负得正
assign over_sum = ( data1_i[31] && data2_mux[31] && !result_sum[31] )
                    ||  ( !data1_i[31] && !data2_mux[31] && result_sum[31] );

/* 
    操作数 1 是否 小于 操作数 2 
        有符号数的话，要看两个数相减的结果，
            (1) 负 < 正
            (2) 正 - 正 < 0
            (3) 负 - 负 < 0
        无符号数的话，直接比较
    看来 verilog 的比较运算符是当作无符号数比较的
*/
assign data1_lt_data2 = ( aluop_i == `EXE_SLT_OP) ?
                            ( (  data1_i[31] && !data2_i[31])
                            || ( data1_i[31] &&  data2_i[31] && result_sum[31])
                            || (!data1_i[31] && !data2_i[31] && result_sum[31]) )
                            : (data1_i < data2_i);

// 操作数 1 取反,为了计算左边的 0 有多少更省力
assign data1_not = ~data1_i;



/* 
    得到最新的HI、LO寄存器的值，此处要解决数据相关问题
 */
always@(*) begin
    if(rst) begin
        {HI,LO} = { `ZeroWord,`ZeroWord };
    end else if (mem_whilo_i) begin            //访存阶段要写HILO
        {HI,LO} = { mem_hi_i, mem_lo_i };
    end else if(wb_whilo_i) begin              //回写阶段要写HILO
        {HI,LO} = { wb_hi_i, wb_lo_i };
    end else begin
        {HI,LO} = { hi_i, lo_i};
    end
end

/* 
    算术运算部分
 */
always @(*) begin
    if(rst) begin
        arith_out = `ZeroWord;
    end else begin
        case(aluop_i)
            `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                arith_out = result_sum;
            end
            `EXE_SUB_OP, `EXE_SUBU_OP: begin
                arith_out = result_sum;
            end
            `EXE_SLT_OP, `EXE_SLTU_OP: begin
                arith_out = data1_lt_data2;
            end
            `EXE_CLO_OP: begin                 //左边有几个 1
                arith_out = data1_not[31] ? 0 : data1_not[30] ? 1 : data1_not[29] ? 2 :
													 data1_not[28] ? 3 : data1_not[27] ? 4 : data1_not[26] ? 5 :
													 data1_not[25] ? 6 : data1_not[24] ? 7 : data1_not[23] ? 8 : 
													 data1_not[22] ? 9 : data1_not[21] ? 10 : data1_not[20] ? 11 :
													 data1_not[19] ? 12 : data1_not[18] ? 13 : data1_not[17] ? 14 : 
													 data1_not[16] ? 15 : data1_not[15] ? 16 : data1_not[14] ? 17 : 
													 data1_not[13] ? 18 : data1_not[12] ? 19 : data1_not[11] ? 20 :
													 data1_not[10] ? 21 : data1_not[9] ? 22 : data1_not[8] ? 23 : 
													 data1_not[7] ? 24 : data1_not[6] ? 25 : data1_not[5] ? 26 : 
													 data1_not[4] ? 27 : data1_not[3] ? 28 : data1_not[2] ? 29 : 
													 data1_not[1] ? 30 : data1_not[0] ? 31 : 32 ;
            end
            `EXE_CLZ_OP: begin              //左边有几个 0 
                arith_out = data1_i[31] ? 0 : data1_i[30] ? 1 : data1_i[29] ? 2 :
													 data1_i[28] ? 3 : data1_i[27] ? 4 : data1_i[26] ? 5 :
													 data1_i[25] ? 6 : data1_i[24] ? 7 : data1_i[23] ? 8 : 
													 data1_i[22] ? 9 : data1_i[21] ? 10 : data1_i[20] ? 11 :
													 data1_i[19] ? 12 : data1_i[18] ? 13 : data1_i[17] ? 14 : 
													 data1_i[16] ? 15 : data1_i[15] ? 16 : data1_i[14] ? 17 : 
													 data1_i[13] ? 18 : data1_i[12] ? 19 : data1_i[11] ? 20 :
													 data1_i[10] ? 21 : data1_i[9] ? 22 : data1_i[8] ? 23 : 
													 data1_i[7] ? 24 : data1_i[6] ? 25 : data1_i[5] ? 26 : 
													 data1_i[4] ? 27 : data1_i[3] ? 28 : data1_i[2] ? 29 : 
													 data1_i[1] ? 30 : data1_i[0] ? 31 : 32 ;
            end
            default begin
                arith_out = `ZeroWord;
            end
        endcase
    end
end

/*
    乘法运算部分
    verilog 自带的乘法运算都是当作无符号数来算的。
    所以 
        如果是有符号的乘法，
        要先算两个数绝对值，

*/
assign op1_mult = ( (aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) )
                                                && data1_i[31]  
                    ? (~data1_i + 1) : data1_i ;

assign op2_mult = ( (aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) )
                                                && data2_i[31]  
                    ? (~data2_i + 1) : data2_i ;

assign hilo_temp = op1_mult * op2_mult;


always @(*) begin
    if(rst) begin
        mul_out = `DoubleZero;
    end else if( ( aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ) begin     
                                                //如果是有符号乘法
        if(data1_i[31] ^ data2_i[31]) begin     //一正一负
            mul_out = ~hilo_temp + 1;          //结果取相反数
        end else begin
            mul_out = hilo_temp;
        end

    end else begin
        mul_out = hilo_temp;
    end
end



/* 
    移动指令运算部分
 */
 always @(*) begin
     if (rst) begin
         move_out = `ZeroWord;
     end else begin
         move_out = `ZeroWord;
         case(aluop_i)
            `EXE_MOVN_OP:begin      //movn：rs -> rd
                move_out = data1_i;
            end
            `EXE_MOVZ_OP:begin      //movz：rs -> rd
                move_out = data1_i;
            end
            `EXE_MFHI_OP:begin      //mfhi：hi -> rd
                move_out = HI;
            end
            `EXE_MFLO_OP:begin      //mflo：lo -> rd
                move_out = LO;
            end
            default begin
                move_out = `ZeroWord;
            end
        endcase
     end
 end

/* 
    逻辑运算部分 
*/
always @(*) begin
    if(rst) begin
        logic_out = `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_AND_OP: begin
                logic_out = data1_i & data2_i;
            end
            `EXE_OR_OP : begin
                logic_out = data1_i | data2_i;
            end
            `EXE_NOR_OP: begin
                logic_out = ~(data1_i | data2_i);
            end
            `EXE_XOR   : begin
                logic_out = data1_i ^ data2_i;
            end
            default:begin
                logic_out = `ZeroWord;
            end
        endcase
    end
end

/* 
    移位运算部分
 */
always @(*) begin
    if(rst) begin
        shift_out = `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLL_OP: begin          //逻辑左移
                shift_out = data2_i << data1_i[4:0];
            end
            `EXE_SRL_OP : begin         //逻辑右移
                shift_out = data2_i >> data1_i[4:0];
            end
            `EXE_SRA_OP : begin         //算数右移
                shift_out = ( { 32{data2_i[31]} } << ~data1_i[4:0] ) | (data2_i >> data1_i[4:0]);
            end
            default:begin
                shift_out = `ZeroWord;
            end
        endcase
    end
end


/* 
    第二段：依据alusel_i指示的运算大类进行结果输出
 */
always @(*) begin
    
    waddr_o = waddr_i;

    /* add、addi、sub、subi要判断溢出，
        如果溢出了就不写寄存器
     */
    if ( (aluop_i == `EXE_ADD_OP || aluop_i == `EXE_SUB_OP)
            && over_sum ) begin
        we_o = `Disable;
    end else begin
        we_o = we_i;
    end
    
    case (alusel_i)
        `EXE_RES_LOGIC: begin           //运算大类是逻辑运算
            result_o = logic_out;       //把逻辑运算的结果输出
        end
        `EXE_RES_SHIFT: begin           //运算大类是移位操作
            result_o = shift_out;       //把移位操作的结果输出
        end
        `EXE_RES_MOVE: begin
            result_o = move_out;
        end
        `EXE_RES_ARITHMETIC: begin      //除乘法外的简单算术指令
            result_o = arith_out;
        end
        `EXE_RES_MUL: begin             //乘法指令结果
            result_o = mul_out[31:0];
        end
        default:begin
            result_o = `ZeroWord;
        end
    endcase
    
end


 /* 
    MTHI、MTLO两条指令,要
    要对hilo部分进行读写。

    可以把 regfile 系
        和 hilo 系的指令看成两条并行的流水线
 */
always @(*) begin
    if(rst) begin
        whilo_o = `Disable;
        hi_o    = `ZeroWord;
        lo_o    = `ZeroWord;
    end else begin
        case(aluop_i)
            `EXE_MTHI_OP:begin      //rs -> hi，lo保持不变
                whilo_o = `Enable;
                hi_o    = data1_i;
                lo_o    = LO;
            end       
            `EXE_MTLO_OP:begin      //rs -> lo，hi保持不变
                whilo_o = `Enable;
                hi_o    = HI;
                lo_o    = data1_i;
            end
            `EXE_MULT_OP, `EXE_MULTU_OP: begin     //乘法结果 -> hilo
                whilo_o = `Enable;                  
                hi_o    = mul_out[63:32];
                lo_o    = mul_out[31:0];
            end
            default begin
                whilo_o = `Disable;
                hi_o    = `ZeroWord;
                lo_o    = `ZeroWord;
            end
        endcase
    end
end


endmodule //ex