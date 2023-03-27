module edg_detector_2 (
    input       clk,
    input       rst,
    input       signal,     //输入信号
    output      pedge,      //检测上升沿输出
    output      nedge       //检测下降沿输出
);

reg [1:0] data;             //定义两个寄存器

always @(posedge clk or posedge rst) begin
    if(rst) begin
        data <=2'b00;                   //复位
    end
    else begin
        data <= {data[0],signal};       //寄存
    end
end

assign nedge = (~data[0])&(data[1]);    //检测下降沿
assign pedge = (~data[1])&(data[0]);    //检测上升沿

wire pos_neg = data[1]^data[0];         //检测有无上升沿或者下降沿

endmodule