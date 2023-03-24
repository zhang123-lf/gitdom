`timescale 1ps/1ps
module fdiv_tb ();
reg inclk,rst;
wire ms_clk,s_clk;
initial begin
    rst=1;
    inclk=0;
    forever begin
        # 2 inclk = ~inclk;
    end
end
initial begin
    # 20 rst = 0;
end
fdiv myfdiv(
    .inclk(inclk),
    .rst(rst),
    .ms_clk(ms_clk),
    .s_clk(s_clk)
);

endmodule