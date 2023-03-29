`timescale 1ps/1ps
module rv_tb (
);
    parameter PERIOD = 10;
    reg clk,rx,bd8_rate,rst;
    wire [7:0] rx_data;
    wire rx_rdy;

    reg [6:0]sample_count;
    wire bd_rate;
    initial begin
        clk = 0;
        #(PERIOD/2);
        forever begin
            #(PERIOD/2) clk=~clk;
        end
    end

    initial begin
        rst = 1;
        #PERIOD rst = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sample_count <= 0;
            rx <= 0;
        end else begin
            if (bd8_rate) begin
                
            end
        end
    end

    baud_rate_en baud_rate_en_inst(
        .rst(rst),
        .clk(clk),
        .rx_bd_en(bd8_rate),
        .tx_bd_en(bd_rate)
    );

    rx rx_inst (
        .rst(rst),
        .clk(clk),
        .bd8_rate(bd8_rate),
        .rx_data(rx_data),
        .rx_rdy(rx_rdy),
        .rx(rx)
    );
endmodule