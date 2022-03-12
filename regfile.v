`include "define.vh"

/* 
    Regfile模块，定义32个32位的通用寄存器
    有2个读端口、一个写端口.

    写是执行阶段完成后、访存、回写，来自mem_wb模块
    读取数据是传给译码阶段的，读数据来源id模块、去处也是id模块
 */

module regfile (
    input   wire    clk,
    input   wire    rst,

    //写端口
    input   wire    we,                     //写使能
    input   wire[`RegAddrBus]    waddr,     //写地址
    input   wire[`RegDataBus]    wdata,     //写数据

    //读端口1
    input   wire    re1,                   //读使能
    input   wire[`RegAddrBus]    raddr_1,   //读地址
    output  reg[`RegDataBus]     rdata_1,   //读出的数据

    //读端口2
    input   wire    re2,
    input   wire[`RegAddrBus]    raddr_2,
    output  reg[`RegDataBus]     rdata_2
);

//32个32位通用寄存器
//地址要不要设成0：`RegNum-1，会不会和大小端有关？？？
reg [`RegDataBus] regs[0 : `RegNum-1];


/************************** 
            写操作
 规定地址为0的寄存器内容是0，不能写入
 **************************/
 always @(posedge clk ) begin
     if(~rst) begin
         if ( we && waddr != `RegAddr_0) begin
             regs[waddr] <= wdata;
         end
     end
 end


 /***************************
            读操作1
    如果同时对一个寄存器进行读、写，
    那么直接把写入的值读出，
    这样解决了隔两条指令的数据冲突
 ***************************/

 always @(posedge clk ) begin
     if(rst) begin
         rdata_1 <= `ZeroWord;
     end else if(raddr_1 == `RegAddr_0) begin
         rdata_1 <= 0;
     end else if(raddr_1 == waddr && we && re1) begin
         rdata_1 <= wdata;                  //同时对一个寄存器读、写,直接把写的数据读出
     end else if(re1) begin
         rdata_1 <= regs[raddr_1];
     end else begin
         rdata_1 <= `ZeroWord;
     end
 end

  /***************************
            读操作2
 ***************************/

 always @(posedge clk ) begin
     if(rst) begin
         rdata_2 <= `ZeroWord;
     end else if(raddr_2 == `RegAddr_0) begin
         rdata_2 <= 0;
     end else if(raddr_2 == waddr && we && re2) begin
         rdata_2 <= wdata;                  //同时对一个寄存器读、写
     end else if(re2) begin
         rdata_2 <= regs[raddr_2];
     end else begin
         rdata_2 <= `ZeroWord;
     end
 end



endmodule //regfile