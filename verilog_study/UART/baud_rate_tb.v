`timescale 100ps/1ps
module baud_rate_tb();
parameter PERIOD = 1;
reg clk;
reg rst;
wire tx_clk;
wire rx_clk;

initial begin
    clk = 0;
    #(PERIOD*3) ;
    forever begin
        #(PERIOD*2)     clk = ~clk;
    end
end
initial begin
    rst = 1;
    # 10
        rst = 0;
end

baud_rate_clk      #(
    .BAUD_RATE  (115200),
    .FREQUENCY  (100000000)
)
baud_rate_clk_inst  (
    .clk(clk),
    .rst(rst),
    .tx_clk(tx_clk),
    .rx_clk(rx_clk)
);

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,baud_rate_tb);
    #1000000000 $finish;
end
endmodule