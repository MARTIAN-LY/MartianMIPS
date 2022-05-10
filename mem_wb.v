`include "define.vh"
/*  
    访存与回写阶段的过渡阶段，
    与 mem 模块十分类似，
    但这个阶段是时序逻辑电路，抗干扰。
    回写阶段直接把 mem_wb 模块与 Regfile模块连接，
    回写的逻辑在 Regfile 模块实现
*/
module mem_wb (
    input   wire    clk,
    input   wire    rst,

    input   wire[5:0]   stall,

    //来自mem模块的数据
    input   wire                mem_we,
    input   wire[`RegAddrBus]   mem_waddr,
    input   wire[`RegDataBus]   mem_result,
    input   wire[`RegDataBus]   mem_hi,
    input   wire[`RegDataBus]   mem_lo,
    input   wire                mem_whilo,

    //回写给Regfile模块的数据
    output  reg                 wb_we,
    output  reg[`RegAddrBus]    wb_waddr,
    output  reg[`RegDataBus]    wb_result,
    output  reg[`RegDataBus]    wb_hi,
    output  reg[`RegDataBus]    wb_lo,
    output  reg                 wb_whilo
);

always @(posedge clk ) begin
    if(rst) begin
        wb_we      <= `Disable;
        wb_waddr   <= `RegAddr_0;
        wb_result  <= `ZeroWord;
        wb_hi      <= `ZeroWord;
        wb_lo      <= `ZeroWord;
        wb_whilo   <= `Disable;
    end 
    /* 
        访存阶段暂停，回写阶段继续
     */
    else if(stall[4] && !stall[5])begin
        wb_we      <= `Disable;
        wb_waddr   <= `RegAddr_0;
        wb_result  <= `ZeroWord;
        wb_hi      <= `ZeroWord;
        wb_lo      <= `ZeroWord;
        wb_whilo   <= `Disable;
    end
    /* 
        访存阶段不暂停
     */
    else if(!stall[4]) begin
        wb_we      <= mem_we;
        wb_waddr   <= mem_waddr;
        wb_result  <= mem_result;
        wb_hi      <= mem_hi;
        wb_lo      <= mem_lo;
        wb_whilo   <= mem_whilo;
    end else begin
        wb_we      <= wb_we;
        wb_waddr   <= wb_waddr;
        wb_result  <= wb_result;
        wb_hi      <= wb_hi;
        wb_lo      <= wb_lo;
        wb_whilo   <= wb_whilo;
    end
end

endmodule //mem_wb