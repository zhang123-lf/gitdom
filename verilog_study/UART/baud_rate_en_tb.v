`timescale 1ns/1ps        
module baud_rate_en_tb();   //modelsim仿真通过
parameter PERIOD = 10; //100MHz
reg clk;
reg rst;
wire tx_bd_en;
wire rx_bd_en;

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

baud_rate_en      #(
    .BAUD_RATE  (115200),
    .FREQUENCY  (100000000)
)
baud_rate_en_inst  (
    .clk(clk),
    .rst(rst),
    .tx_bd_en(tx_bd_en),
    .rx_bd_en(rx_bd_en)
);

//initial begin
   // $fsdbDumpfile("tb.fsdb");
  //  $fsdbDumpvars(0,baud_rate_tb);
  //  #(5000*PERIOD) $finish;
//end
endmodule