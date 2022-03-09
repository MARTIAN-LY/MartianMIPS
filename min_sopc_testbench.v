`include "define.vh"

//时间单位是1ns,精度是1ps
`timescale 1ns/1ps

module min_sopc_testbench ();

reg clk_50;
reg rst;

//每隔10ns,clk_50反转一次，所以一个周期是20ns，对应50MHz
initial begin
    clk_50 = 1'b0;
    forever #10 clk_50 = ~clk_50;
end

//最初时刻，复位信号有效，在第195ns，复位信号无效，最小SOPC开始运行
//运行1000ns，停止仿真
initial begin
   rst      = `Enable;
   #195 rst = `Disable;
   #1000 $stop;  
end


//例化min_sopc
min_sopc min_sopc0(
    .clk(clk_50),
    .rst(rst)
);

endmodule //min_sopc_testbench