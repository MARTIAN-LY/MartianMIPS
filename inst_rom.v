`include "define.vh"

/* 
    指令存储器。
    一条指令32位。
    但是按字节寻址，传过来的地址是字节地址，
    要获取一条指令的地址，传过来的地址除4，相当于右移两位
 */
module inst_rom(
    input   wire                ce,
    input   wire[`InstAddrBus]  addr,
    output  reg[`InstBus]       inst
);

//定义二维存储器，宽度 32 位，深度是2^17
reg[`InstBus]   inst_mem[0:`InstMemNum-1];

initial begin
    //用绝对路径
    $readmemh("D:/study/verilog/MartianMIPS/code/inst_rom.data",inst_mem);
end

always @(*) begin
    if(~ce) begin
        inst = `ZeroWord;
    end else begin
        inst = inst_mem[ addr[`InstBusUsed+1 : 2] ];
    end
end

endmodule //inst_rom