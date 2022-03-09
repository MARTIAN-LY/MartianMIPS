`include "define.vh"

/* 
    访存阶段
    把运算结果给回写阶段，是组合逻辑电路
 */
module mem (
    input   wire    rst,

    //来自执行阶段的数据
    input   wire[`RegDataBus]   result_i,
    input   wire[`RegAddrBus]   waddr_i,
    input   wire                we_i,

    //送到回写阶段的数据
    output  reg[`RegDataBus]    result_o,
    output  reg[`RegAddrBus]    waddr_o,
    output  reg                 we_o
);

always @(*) begin
    if (rst) begin
        result_o = `ZeroWord;
        waddr_o  = `RegAddr_0;
        we_o     = `Disable;
    end else begin
        result_o = result_i;
        waddr_o  = waddr_i;
        we_o     = we_i;
    end
end

endmodule //mem


