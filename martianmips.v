`include "define.vh"


module martianmips (
    input   wire    clk,
    input   wire    rst,

    input   wire[`RegDataBus]   rom_data_i,
    output  reg[`RegDataBus]    rom_addr_o,
    output  wire                rom_ce_o
);

//连接IF/ID模块与ID模块的变量
wire[`InstAddrBus]  pc;



//pc_reg模块例化
pc_reg  pc_reg0(
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .ce(rom_ce_o)
);



endmodule //martianmips