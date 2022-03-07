`include "define.vh"

/* 
    PC模块，给出指令的地址，并进行自增
 */

module pc_reg (
    input   wire    clk,
    input   wire    rst,
    output  reg     ce,                 //ָ指令存储器的使能信号
    output  reg[`InstAddrBus]    pc     //ָ指令的地址
);

always @(posedge clk) begin
    if (rst) begin
        ce <= `Disable;                 //复位时指令存储器禁用         
    end else begin
        ce <= `Enable;                  //复位结束，指令存储器使能
    end
end


always @(posedge clk ) begin
    if(rst) begin
        pc <= 0;
    end else begin
        pc <= pc + 4;                   //按字节寻址，一条指令32位，下一条指令地址 = 现地址 + 4
    end
end

endmodule //pc_reg