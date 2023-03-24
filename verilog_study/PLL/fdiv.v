//输入时钟100M，设计分频器产生毫秒和秒时钟脉冲     
module fdiv (
    input           inclk,
    input           rst,
    output  reg     ms_clk,
    output  reg     s_clk
);
reg     [16:0]      ms_r;
reg     [9:0]       s_r;

always@(posedge inclk or posedge rst ) begin
    if(rst) begin
        ms_r <= 0;
        ms_clk <= 0;
    end
    else    begin
        if (ms_r==49) begin
            ms_clk <= ~ms_clk;
            ms_r <= 0;
        end
        else begin
            ms_r<=ms_r+1;
        end
    end
end
always@(posedge ms_clk or posedge rst) begin
    if(rst) begin
        s_r <= 0;
        s_clk <= 0;
    end
    else    begin
        if (s_r==49) begin
            s_clk <= ~s_clk;
            s_r <= 0;
        end
        else begin
            s_r <=s_r+1;
        end
    end
end



endmodule