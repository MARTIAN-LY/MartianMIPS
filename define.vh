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


//r型special
`define EXE_SPECIAL 6'b000000           //special类型指令
`define EXE_AND     6'b100100           //and
`define EXE_OR      6'b100101           //or
`define EXE_XOR     6'b100110           //xor
`define EXE_NOR     6'b100111           //nor：或非
`define EXE_SLL     6'b000000           //逻辑左移
`define EXE_SLLV    6'b000100           //逻辑左移
`define EXE_SRL     6'b000010           //逻辑右移
`define EXE_SRLV    6'b000110           //逻辑右移
`define EXE_SRA     6'b000011           //算数右移
`define EXE_SRAV    6'b000111           //算数右移
`define EXE_NOP     6'b000000           //空指令
`define EXE_SYNC    6'b001111


//i型
`define EXE_ANDI    6'b001100
`define EXE_ORI     6'b001101           
`define EXE_XORI    6'b001110
`define EXE_LUI     6'b001111           //lui：把立即数存到指定寄存器
`define EXE_PREF    6'b110011



/* 
    alu 只认 and、or、nor、xor、sll、srl、sra
    有些没用上啊？？？？？？ 
*/
//AluOp，alu识别指令的时候要的是八位
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP   8'b00100110
`define EXE_NOR_OP   8'b00100111
`define EXE_ANDI_OP  8'b01011001    
`define EXE_ORI_OP   8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP   8'b01011100   

`define EXE_SLL_OP   8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP   8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP   8'b00000011
`define EXE_SRAV_OP  8'b00000111

`define EXE_NOP_OP   8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001            //运算大类是逻辑运算
`define EXE_RES_SHIFT 3'b010            //运算大类是移位运算

`define EXE_RES_NOP 3'b000




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
