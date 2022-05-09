`include "define.vh"

module hilo_reg (
    input   wire                clk,
    input   wire                rst,

    //写端口
    input   wire                we,
    input   wire[`RegDataBus]   hi_i,
    input   wire[`RegDataBus]   lo_i,

    //读端口
    output  reg[`RegDataBus]    hi_o,
    output  reg[`RegDataBus]    lo_o
);

always @(posedge clk ) begin
    if(rst) begin
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end else if(we) begin
        hi_o <= hi_i;
        lo_o <= lo_i;
    end else begin
        hi_o <= hi_o;
        lo_o <= lo_o;
    end
end

endmodule //hilo