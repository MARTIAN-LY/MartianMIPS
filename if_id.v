`include "define.vh"

/*  
    if_id模块是 取指 和 译码 的中间模块。
    作用好像有暂存从PC取出的地址，
             暂存取到的指令，
    这么说像是MAR和MDR？？？
 */

module if_id (
    input   wire    clk,
    input   wire    rst,
    input   wire[`InstAddrBus]  if_pc,       //从pc中取出来的指令地址，32位
    input   wire[`InstBus]      if_inst,     //这TM直接就是取到的指令？？？
    output  reg[`InstAddrBus]   id_pc,       //把地址传给主存？
    output  reg[`InstBus]       id_inst      //这TM直接把指令送出去？？？
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