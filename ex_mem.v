`include "define.vh"

/* 
    ex_mem模块,执行阶段与访存阶段之间的过渡阶段。
    将来自执行阶段的运算结果传给访存阶段
 */

module ex_mem (
    input   wire    clk,
    input   wire    rst,

    //来自执行阶段的信息
    input   wire[`RegDataBus]   ex_result,
    input   wire                ex_we,
    input   wire[`RegAddrBus]   ex_waddr,
    input   wire[`RegDataBus]   ex_hi,
    input   wire[`RegDataBus]   ex_lo,
    input   wire                ex_whilo,

    //送访存阶段的信息
    output  reg[`RegDataBus]   mem_result,
    output  reg                mem_we,
    output  reg[`RegAddrBus]   mem_waddr,
    output  reg[`RegDataBus]   mem_hi,
    output  reg[`RegDataBus]   mem_lo,
    output  reg                mem_whilo
);

always @(posedge clk) begin
    if(rst) begin
        mem_result <= `ZeroWord;
        mem_we     <= `Disable;
        mem_waddr  <= `RegAddr_0;
        mem_hi     <= `ZeroWord;
        mem_lo     <= `ZeroWord;
        mem_whilo  <= `Disable;
    end else begin
        mem_result <= ex_result;
        mem_we     <= ex_we;
        mem_waddr  <= ex_waddr;
        mem_hi     <= ex_hi;
        mem_lo     <= ex_lo;
        mem_whilo  <= ex_whilo;
    end
end

endmodule //ex_mem