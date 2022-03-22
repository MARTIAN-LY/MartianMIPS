`include "define.vh"


/* 
    执行模块，也是一个时序逻辑电路
    根据得到的操作类型、源操作数、写入地址等进行运算
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

    //执行的结果
    output  reg                 we_o,
    output  reg[`RegAddrBus]    waddr_o,
    output  reg[`RegDataBus]    result_o 
);

//暂存运算结果
reg[`RegDataBus]    logic_out;
reg[`RegDataBus]    shift_out;

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
        default:begin
            result_o = `ZeroWord;
        end
    endcase
    
end



endmodule //ex