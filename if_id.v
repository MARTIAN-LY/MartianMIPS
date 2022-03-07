`include "define.vh"

//if_id模块相当于 MAR ,用来暂存从pc中取到的指令地址
//不仅仅相当于 MAR ,好像连 MDR 的功能也包含了

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