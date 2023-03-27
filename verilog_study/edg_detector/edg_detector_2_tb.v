`timescale 10ps/1ps
module edg_detector_2_tb();
parameter PERIOD = 10; //一个周期

wire pedge ,nedge;
reg clk,rst,signal;

initial begin
    rst = 1;
    #PERIOD ;
    #(PERIOD/2) rst =0;
end
initial begin
    clk=0;
    #(PERIOD/2);
    forever begin
        #(PERIOD/2) clk=~clk;
    end
end

initial begin
    signal = 0;
    # 4 signal =1 ;
    # 3 signal = ~signal;
    # PERIOD signal = ~signal;
    # PERIOD signal = ~signal;
    # 3 signal = ~signal;
    # 5 signal = ~signal;
    # 3 signal = ~signal;
    # (PERIOD*3) signal = ~signal;
    # (PERIOD*2) signal = ~signal;
    # (PERIOD*2) signal = ~signal;
    # (PERIOD*4) signal = ~signal;
    # (PERIOD*4) signal = ~signal;
    # 3 signal = ~signal;
end
edg_detector_2 edg_detector_2_inst(
    .clk(clk),
    .rst(rst),
    .signal(signal),
    .nedge(nedge),
    .pedge(pedge)
);
endmodule