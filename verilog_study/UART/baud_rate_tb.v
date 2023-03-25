`timescale 1ns/1ps        //已经通过vcs和verdi
module baud_rate_tb();
parameter PERIOD = 10; //100MHz
reg clk;
reg rst;
wire tx_clk;
wire rx_clk;

initial begin
    clk = 0;
    #(PERIOD/2) ;
    forever begin
        #(PERIOD/2)     clk = ~clk;
    end
end
initial begin
    rst = 1;
    # 50
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
    #(5000*PERIOD) $finish;
end
endmodule
