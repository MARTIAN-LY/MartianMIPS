`include "define.vh"

/* 
    顶层模块
    将各个部件连接起来
 */

module martianmips (
    input   wire    clk,
    input   wire    rst,

    input   wire[`RegDataBus]   rom_data_i,     //读取的指令
    output  reg[`RegDataBus]    rom_addr_o,     //输出的指令地址
    output  wire                rom_ce_o        //rom读取的使能信号
);

//if_id模块的输入
wire[`InstAddrBus]  ifid_pc;


//id模块的输入
wire[`InstAddrBus]  id_pc;
wire[`InstBus]      id_inst;
wire[`RegAddrBus]   id_read1;
wire[`RegAddrBus]   id_read2;


//Regfile模块的输入
wire                regfile_we;
wire[`RegAddrBus]   regfile_waddr;
wire[`RegDataBus]   regfile_wdata;
wire                regfile_re1;
wire[`RegAddrBus]   regfile_raddr1;
wire                regfile_re2;
wire[`RegAddrBus]   regfile_raddr2;

//id_ex模块的输入
wire[`AluOpBus]     idex_aluop;
wire[`AluSelBus]    idex_alusel;
wire[`RegDataBus]   idex_data1;
wire[`RegDataBus]   idex_data2;
wire[`RegAddrBus]   idex_waddr;
wire                idex_we;


//pc_reg模块例化
pc_reg  pc_reg0(
    .clk(clk),
    .rst(rst),
    output  reg     ce,                 //ָ指令存储器的使能信号
    output  reg[`InstAddrBus]    pc     //ָ指令的地址
);

//if_id模块例化
if_id if_id0(
    .clk(clk),
    .rst(rst),
    .if_pc(ifid_pc),        //从pc中取出来的指令地址，32位
    .if_inst(rom_data_i),   //这TM直接就是取到的指令？？？
    output  reg[`InstAddrBus]   id_pc,       //把地址传给主存？
    output  reg[`InstBus]       id_inst      //这TM直接把指令送出去？？？
);

//id模块的例化
id id0(
    .rst(rst),
    .pc_i(id_pc),           //指令地址
    .inst_i(id_inst),       //指令内容

    //读取Regfile
    output  reg                 re1_o,
    output  reg                 re2_o,
    output  reg[`RegAddrBus]    raddr1_o,
    output  reg[`RegAddrBus]    raddr2_o,
    .rdata1_i(id_read1),
    .rdata2_i(id_read2),     
    
    //写入Regfile
    output  reg                 we_o,
    output  reg[`RegAddrBus]    waddr_o,

    //送到执行阶段的信息
    output  reg[`AluOpBus]      aluop_o,
    output  reg[`AluSelBus]     alusel_o,
    output  reg[`RegDataBus]    data1_o,
    output  reg[`RegDataBus]    data2_o
);

//Regfile模块例化
regfile regfile0(
    .clk(clk),
    .rst(rst),

    //写端口
    .we(regfile_we),           //写使能
    .waddr(regfile_waddr),     //写地址
    .wdata(regfile_wdata),     //写数据

    //读端口1
    .re1(regfile_re1),          //读使能
    .raddr_1(regfile_raddr1),   //读地址
    output  reg[`RegDataBus]     rdata_1,   //读出的数据

    //读端口2
    .re2(regfile_re2),
    .raddr_2(regfile_raddr2),
    output  reg[`RegDataBus]     rdata_2
);


//id_ex模块例化
id_ex id_ex0(
    .clk(clk),
    .rst(rst),

    //从译码阶段传过来的信息
    .id_aluop(idex_aluop),   //操作类型
    .id_alusel(idex_alusel),  //操作子类型
    .id_data1(idex_data1),   //操作数1
    .id_data2(idex_data2),   //操作数2
    .id_waddr(idex_waddr),   //写入地址
    .id_we(idex_we),      //写入使能

   //传给执行阶段的信息
   output  reg[`AluOpBus]      ex_aluop,   //操作类型
   output  reg[`AluSelBus]     ex_alusel,  //操作子类型
   output  reg[`RegDataBus]    ex_data1,   //操作数1
   output  reg[`RegDataBus]    ex_data2,   //操作数2
   output  reg[`RegAddrBus]    ex_waddr,   //写入地址
   output  reg                 ex_we       //写入使能
);

//ex模块例化
ex ex0(
    input   wire    rst,

    //接受到的信息
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegDataBus]   data1_i,
    input   wire[`RegDataBus]   data2_i,
    input   wire[`RegAddrBus]   waddr_i,
    input   wire                we_i,

    //执行的结果
    output  reg                 we_o,
    output  reg[`RegAddrBus]    waddr_o,
    output  reg[`RegDataBus]    result_o  
);

//ex_mem模块例化
ex_mem ex_mem0(
    input   wire    clk,
    input   wire    rst,

    //来自执行阶段的信息
    input   wire[`RegDataBus]   ex_result,
    input   wire                ex_we,
    input   wire[`RegAddrBus]   ex_waddr,

    //送访存阶段的信息
    output  reg[`RegDataBus]   mem_result,
    output  reg                mem_we,
    output  reg[`RegAddrBus]   mem_waddr
);

//mem模块例化
mem mem0(
    input   wire    rst,

    //来自执行阶段的数据
    input   wire[`RegDataBus]   result_i,
    input   wire[`RegAddrBus]   waddr_i,
    input   wire                we_i,

    //送到回写阶段的数据
    output  reg[`RegDataBus]    result_o,
    output  reg[`RegAddrBus]    waddr_o,
    output  reg                 we_o
);

//mem_wb模块例化
mem_wb mem_wb0(
    input   wire    clk,
    input   wire    rst,

    //来自mem模块的数据
    input   wire                mem_we,
    input   wire[`RegAddrBus]   mem_waddr,
    input   wire[`RegDataBus]   mem_result,

    //回写给Regfile模块的数据
    output  reg                 wb_we,
    output  reg[`RegAddrBus]    wb_waddr,
    output  reg[`RegDataBus]    wb_result 
)

endmodule //martianmips