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
    output  reg[`RegDataBus]    result_o 
);

//暂存运算结果
reg[`RegDataBus]    logic_out;
reg[`RegDataBus]    shift_out;
reg[`RegDataBus]    move_out;
reg[`RegDataBus]    HI;     //保存 HI 寄存器的最新值
reg[`RegDataBus]    LO;     //保存 LO 寄存器的最新值



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
    we_o    = we_i;
    case (alusel_i)
        `EXE_RES_LOGIC: begin           //运算大类是逻辑运算
            result_o = logic_out;       //把逻辑运算的结果输出
        end
        `EXE_RES_SHIFT: begin           //运算大类是移位操作
            result_o = shift_out;       //把移位操作的结果输出
        end
        `EXE_RES_MOVE:begin
            result_o = move_out;
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
            default begin
                whilo_o = `Disable;
                hi_o    = `ZeroWord;
                lo_o    = `ZeroWord;
            end
        endcase
    end
end


endmodule //ex