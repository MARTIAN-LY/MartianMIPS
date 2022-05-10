`include "define.vh"


/* 
    id_ex模块，在译码和执行阶段的过渡模块。
    作用是将译码阶段得到的运算类型、源操作数、写入的目的寄存器地址等
    传给执行阶段。
 */

 module id_ex (
   input  wire     clk,
   input  wire     rst,

   //从译码阶段传过来的信息
   input  wire[`AluOpBus]      id_aluop,   //操作子类型
   input  wire[`AluSelBus]     id_alusel,  //操作大类型
   input  wire[`RegDataBus]    id_data1,   //操作数1
   input  wire[`RegDataBus]    id_data2,   //操作数2
   input  wire[`RegAddrBus]    id_waddr,   //写入地址
   input  wire                 id_we,      //写入使能
   input  wire[5:0]            stall,      //暂停

   //传给执行阶段的信息
   output  reg[`AluOpBus]      ex_aluop,   //操作子类型
   output  reg[`AluSelBus]     ex_alusel,  //操作类型
   output  reg[`RegDataBus]    ex_data1,   //操作数1
   output  reg[`RegDataBus]    ex_data2,   //操作数2
   output  reg[`RegAddrBus]    ex_waddr,   //写入地址
   output  reg                 ex_we       //写入使能
 );


 always @(posedge clk ) begin
      if(rst) begin
        ex_aluop  <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_data1  <= `ZeroWord;
        ex_data2  <= `ZeroWord;
        ex_waddr  <= `RegAddr_0;
        ex_we     <= `Disable;
      end 
      /* 
         译码阶段暂停，执行阶段继续
      */
      else if(stall[2] && !stall[3])begin
        ex_aluop  <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_data1  <= `ZeroWord;
        ex_data2  <= `ZeroWord;
        ex_waddr  <= `RegAddr_0;
        ex_we     <= `Disable;
      end
      /* 
         译码阶段不暂停
       */
      else if(!stall[2]) begin
        ex_aluop  <= id_aluop;
        ex_alusel <= id_alusel;
        ex_data1  <= id_data1;
        ex_data2  <= id_data2;
        ex_waddr  <= id_waddr;
        ex_we     <= id_we;
      end 
      
      else begin
        ex_aluop  <= ex_aluop;
        ex_alusel <= ex_alusel;
        ex_data1  <= ex_data1;
        ex_data2  <= ex_data2;
        ex_waddr  <= ex_waddr;
        ex_we     <= ex_we;
      end
 end
 
 endmodule //id_ex