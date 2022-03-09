//************  常用的宏定义  ************
`define True     1'b1
`define False    1'b0
`define Enable   1'b1
`define Disable  1'b0
`define ZeroWord 32'h0000_0000          //机器字长32位，定义32位的0


//************  译码阶段的宏定义  ************
`define AluOpBus    7:0                 //译码阶段的输出aluop_o的宽度
`define AluSelBus   2:0                 //译码阶段的输出alusel_o的宽度



//************  与具体指令有关的宏定义  ************
`define EXE_ORI     6'b001101               //ORI指令的指令码
`define EXE_NOP     6'b000000               //空指令

//AluSel
`define EXE_RES_LOGIC   3'b001              //运算类型是逻辑运算
`define EXE_RES_NOP     3'b000              //运算类型是空

//AluOp
`define EXE_OR_OP   8'b0010_0101            //具体运算类型是“逻辑或”
`define EXE_NOP_OP  8'b0000_0000            //具体运算类型是空




//************  与指令存储器ROM有关的宏定义  ************
`define InstAddrBus 31:0                //ROM地址总线宽度是32位
`define InstBus     31:0                //ROM数据总线宽度
`define InstMemNum  131071              //ROM实际大小是128KB，深度是2^17
`define InstBusUsed 17                  //ROM实际使用的地址线宽度是17


//************  与通用寄存器Regfile有关的寄存器
`define RegAddrBus  4:0                 //Regfile模块地址线宽度，32个通用寄存器
`define RegAddrNum  5                   //地址线5条
`define RegAddr_0   5'b00000            //0号地址
`define RegDataBus  31:0                //Regfile模块数据线宽度，32位寄存器             
`define RegWidth    32                  //通用寄存器宽度32位
`define RegNum      32                  //通用寄存器有32个
