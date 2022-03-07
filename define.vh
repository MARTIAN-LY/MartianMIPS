//************  常用的宏定义  ************
`define True 1
`define False 0
`define Enable 1
`define Disable 0
`define ZeroWord 32'h0000_0000          //机器字长32位，定义32位的0


//************  与具体指令有关的宏定义  ************
`define EXE_ORI 6'b001101               //ORI指令的指令码


//************  与指令存储器ROM有关的宏定义  ************
`define InstAddrBus 31:0                //ROM地址总线宽度是32位
`define InstBus     31:0                //ROM数据总线宽度


//************  与通用寄存器Regfile有关的寄存器
`define RegAddrBus  4:0                 //Regfile模块地址线宽度，32个通用寄存器
`define RegAddrNum  5                   //地址线5条
`define RegDataBus  31:0                //Regfile模块数据线宽度，32位寄存器
`define RegDataNum  32                  //数据32位                 
`define RegWidth    32                  //通用寄存器宽度32位
`define RegNum      32                  //通用寄存器有32个