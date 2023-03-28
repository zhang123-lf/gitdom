`timescale 1ps/1ps
module rx_sb_tb (
);
    parameter PERIOD = 10;
    reg clk;
    reg rst;
    wire rx_bd_en;
    wire tx_bd_en;

    wire rx_bit;
    wire rx_bit_rdy;

    reg tx;
    reg [3:0] tx_count;

    initial begin
    clk = 0;
    #(PERIOD/2)
    forever begin
        #(PERIOD/2) clk=~clk;
    end
    end

    initial begin
        rst =1;
        #50 rst =0;
    end

    always @(posedge clk or posedge rst) begin   //提供一个start_bit
        if (rst) begin
            tx_count =0;
            tx = 1'b1;
        end else begin
            if (tx_bd_en) begin
                if (tx_count == 12) begin
                    tx = 1'b0;
                    tx_count = 0;
                end else begin
                    tx_count =tx_count + 1;
                    tx = 1'b1;
                end
            end
        end
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

rx_sb rx_sb_inst (
    .clk(clk),
    .rst(rst),
    .rx(tx),
    .bd8_rate(rx_bd_en),
    .rx_bit(rx_bit),
    .rx_bit_rdy(rx_bit_rdy)
);
endmodule
