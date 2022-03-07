`include "define.vh"

/* 
    id模块，对指令进行译码
    TMD直接组合逻辑，连clk都不要了
 */
module id (
    input   wire                rst,
    input   wire[`InstAddrBus]  pc_i,
    input   wire[`InstBus]      inst_i,

    //读取的Regfile的值
    input   wire[`RegDataBus]   data1_i,
    input   wire[`RegDataBus]   data2_i, 

    //输出到Regfile的值
    output  reg                 re1_o,
    output  reg                 re2_o,
    output  reg[`RegDataBus]    rdata_1_o,
    output  reg[`RegDataBus]    rdata_2_o,

    //送到执行阶段的信息
    output  reg[`AluOpBus]      aluop_o,
    output  reg[`AluSelBus]     alusel_o

);

endmodule //id