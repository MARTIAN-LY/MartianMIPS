//************  常用的宏定义  ************
`define True     1'b1
`define False    1'b0
`define Enable   1'b1
`define Disable  1'b0
`define ZeroWord 32'h0000_0000          //机器字长32位，定义32位的0 
`define DoubleZero 64'h00000000_00000000    //64位的 0


//************  译码阶段的宏定义  ************
`define AluOpBus    7:0                 //具体指定
`define AluSelBus   2:0                 //大类区分


//************  与具体指令有关的宏定义  ************

// 特殊的 opcode
`define EXE_SPECIAL     6'b000000
`define EXE_SPECIAL_2   6'b011100
`define EXE_REGIMME     6'b000001


// opcode是special，由 func 判断指令类型
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
`define EXE_SYNC    6'b001111           //当作空指令

`define EXE_MOVZ    6'b001010
`define EXE_MOVN    6'b001011
`define EXE_MFHI    6'b010000
`define EXE_MTHI    6'b010001
`define EXE_MFLO    6'b010010
`define EXE_MTLO    6'b010011

`define EXE_SLT     6'b101010
`define EXE_SLTU    6'b101011
 
`define EXE_ADD     6'b100000
`define EXE_ADDU    6'b100001
`define EXE_SUB     6'b100010
`define EXE_SUBU    6'b100011

`define EXE_MULT    6'b011000       //乘法，写入 hilo 模块
`define EXE_MULTU   6'b011001       //乘法，写入 hilo 模块

// opcode 是 special2， 由 func 判断
`define EXE_CLZ     6'b100000
`define EXE_CLO     6'b100001
`define EXE_MUL     6'b000010       //乘法，写入 rd


//i型，可以直接由 opcode 判断
`define EXE_ANDI    6'b001100
`define EXE_ORI     6'b001101           
`define EXE_XORI    6'b001110
`define EXE_LUI     6'b001111           //lui：把立即数存到指定寄存器
`define EXE_PREF    6'b110011
`define EXE_ADDI    6'b001000
`define EXE_ADDIU   6'b001001
`define EXE_SLTI    6'b001010
`define EXE_SLTIU   6'b001011  


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

`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011
`define EXE_MFHI_OP  8'b00010000
`define EXE_MTHI_OP  8'b00010001
`define EXE_MFLO_OP  8'b00010010
`define EXE_MTLO_OP  8'b00010011

`define EXE_SLT_OP   8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP 8'b01011000   
`define EXE_ADD_OP   8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP   8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP 8'b01010110
`define EXE_CLZ_OP   8'b10110000
`define EXE_CLO_OP   8'b10110001

`define EXE_MULT_OP  8'b00011000
`define EXE_MULTU_OP 8'b00011001
`define EXE_MUL_OP   8'b10101001

`define EXE_NOP_OP   8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001            //运算大类是逻辑运算
`define EXE_RES_SHIFT 3'b010            //运算大类是移位运算
`define EXE_RES_MOVE  3'b011	        //运算大类是移动运算
`define EXE_RES_ARITHMETIC 3'b100	    //运算大类是算数运算
`define EXE_RES_MUL 3'b101              //运算大类是乘法运算

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
`define DoubleWordBus 63:0              //64位
