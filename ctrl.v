module ctrl (
    input  wire     rst,
    input  wire     stall_from_id,  //来自译码阶段的暂停请求
    input  wire     stall_from_ex,  //来自执行阶段的暂停请求
    output reg[5:0] stall           //控制各个阶段是否停止的信号
);

always@(*) begin
    if(rst) begin
        stall = 6'b000000;
    end else if(stall_from_ex)begin
        stall = 6'b001111;
    end else if(stall_from_id) begin
        stall = 6'b000111;
    end else begin
        stall = 6'b000000;
    end
end

endmodule //ctrl