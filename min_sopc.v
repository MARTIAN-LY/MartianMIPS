`include "define.vh"

/* 
    建立一个SOPC模块，对其进行验证 
    目前仅包含martianmips和ROM，是一个最小SOPC
 */

module min_sopc (
    input   wire   clk,
    input   wire   rst
);

//martianmips的输入
wire[`InstBus]  mips_data_i;

//指令存储器的输入
wire[`InstAddrBus]  rom_addr;
wire                rom_ce;

martianmips martianmips0(
    .clk(clk),
    .rst(rst),
    .rom_data_i(mips_data_i),
    .rom_ce_o(rom_ce),
    .rom_addr_o(rom_addr)
);

inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(rom_addr),
    .inst(mips_data_i)
);

endmodule //min_sopc