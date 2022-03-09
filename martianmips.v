`include "define.vh"

/* 
    顶层模块
    将各个部件连接起来.

    译码id模块，
    执行ex模块，
    访存mem模块（为什么存在？？？）
        是组合逻辑
        其余都是时序逻辑
 */

module martianmips (
    input   wire    clk,
    input   wire    rst,

    input   wire[`RegDataBus]   rom_data_i,     //读取的指令
    output  wire[`RegDataBus]   rom_addr_o,     //输出的指令地址
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


//ex模块的输入
wire[`AluOpBus]    ex_aluop;
wire[`AluSelBus]   ex_alusel;
wire[`RegDataBus]  ex_data1;
wire[`RegDataBus]  ex_data2;
wire[`RegAddrBus]  ex_waddr;
wire               ex_we;

//ex_mem模块的输入
wire[`RegDataBus]   exmem_result;
wire                exmem_we;
wire                exmem_waddr;

//mem模块输入
wire[`RegDataBus]    mem_result;
wire[`RegAddrBus]    mem_waddr;
wire                 mem_we;

//mem_wb模块的输入
wire                memwb_we;
wire[`RegAddrBus]   memwb_waddr;
wire[`RegDataBus]   memwb_result;


//pc_reg模块例化
pc_reg  pc_reg0(
    .clk(clk),
    .rst(rst),
    .ce(rom_ce_o),                 //ָ指令存储器的使能信号
    .pc(ifid_pc)     //ָ指令的地址
);

//pc直接把地址传给指令存储器
assign rom_addr_o = ifid_pc;

//读取的指令先存到id_id模块
//if_id模块例化
if_id if_id0(
    .clk(clk),
    .rst(rst),
    .if_pc(ifid_pc),        //从pc中取出来的指令地址，32位
    .if_inst(rom_data_i),   //这TM直接就是取到的指令
    .id_pc(id_pc),       
    .id_inst(id_inst)      //这TM直接把指令送给译码阶段
);

//id模块的例化
id id0(
    .rst(rst),
    .pc_i(id_pc),           //指令地址
    .inst_i(id_inst),       //指令内容

    //读取Regfile
    .re1_o(regfile_re1),
    .re2_o(regfile_re2),
    .raddr1_o(regfile_raddr1),
    .raddr2_o(regfile_raddr2),
    .rdata1_i(id_read1),
    .rdata2_i(id_read2),     
    
    //写入Regfile
    //现在结果还没出来，所以写结果不是id模块的事，把信号传给后面
    .we_o(idex_we),
    .waddr_o(idex_waddr),

    //送到执行阶段的信息
    .aluop_o(idex_aluop),
    .alusel_o(idex_alusel),
    .data1_o(idex_data1),
    .data2_o(idex_data2)
);

//Regfile模块例化
//写是执行阶段完成后、访存、回写，来自mem_wb模块
//读取数据是传给译码阶段的，读数据来源id模块、去处也是id模块
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
    .rdata_1(id_data1),   //读出的数据

    //读端口2
    .re2(regfile_re2),
    .raddr_2(regfile_raddr2),
    .rdata_2(id_data2)
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
    .ex_aluop(ex_aluop),   //操作类型
    .ex_alusel(ex_alusel),  //操作子类型
    .ex_data1(ex_data1),   //操作数1
    .ex_data2(ex_data2),   //操作数2
    .ex_waddr(ex_waddr),   //写入地址
    .ex_we(ex_we)       //写入使能
);



//ex模块例化
ex ex0(
    .rst(rst),

    //接受到的信息
    .aluop_i(ex_aluop),
    .alusel_i(ex_alusel),
    .data1_i(ex_data1),
    .data2_i(ex_data2),
    .waddr_i(ex_waddr),
    .we_i(we),

    //执行的结果
    .we_o(exmem_we),
    .waddr_o(exmem_waddr),
    .result_o(exmem_result)  
);



//ex_mem模块例化
ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),

    //来自执行阶段的信息
    .ex_result(exmem_result),
    .ex_we(exmem_we),
    .ex_waddr(exmem_waddr),

    //送访存阶段的信息
    .mem_result(mem_result),
    .mem_we(mem_we),
    .mem_waddr(mem_waddr)
);


//mem模块例化
mem mem0(
    .rst(rst),

    //来自执行阶段的数据
    .result_i(mem_result),
    .waddr_i(mem_waddr),
    .we_i(mem_we),

    //送到回写阶段的数据
    .result_o(memwb_result),
    .waddr_o(memwb_waddr),
    .we_o(memwb_we)
);


//mem_wb模块例化
mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),

    //来自mem模块的数据
    .mem_we(memwb_we),
    .mem_waddr(memwb_waddr),
    .mem_result(memwb_result),

    //回写给Regfile模块的数据
    .wb_we(regfile_we),
    .wb_waddr(regfile_waddr),
    .wb_result(regfile_wdata) 
);

endmodule //martianmips