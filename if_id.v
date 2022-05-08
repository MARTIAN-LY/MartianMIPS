`include "define.vh"

/*  
    if_id模块是 取指 和 译码 的中间模块。
    作用有暂存 pc 的值，
        暂存取到的指令，
 */

module if_id (
    input   wire    clk,
    input   wire    rst,
    input   wire[`InstAddrBus]  if_pc,       // pc 的值
    input   wire[`InstBus]      if_inst,     //取到的指令
    output  reg[`InstAddrBus]   id_pc,       
    output  reg[`InstBus]       id_inst      //把指令传给译码阶段
);

always @(posedge clk ) begin
    if(rst) begin
        id_pc   <= `ZeroWord;
        id_inst <= `ZeroWord;               //复位的时候指令是0，也就是空指令
    end else begin
        id_pc   <= if_pc;                   //其余时刻向下传递指令的值
        id_inst <= if_inst;
    end
end

endmodule //if_id