`timescale 1ps/1ps
module rx_tb (
);
    parameter PERIOD = 10;
    reg clk,tx,bd8_rate,rst;
    wire [7:0] rx_data;
    wire rx_rdy;

    reg [6:0]sample_count;
    reg [1:0] sample_st;
    reg  [7:0] tx_data=8'h66;
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
            tx <= 0;
            sample_st <= 0;
        end else begin
            if (bd_rate) begin
                case (sample_st)
                    0:begin
                        sample_count <= sample_count + 1;
                        tx <= 1;
                        if (sample_count == 10) begin
                            sample_count <= 0;
                            sample_st <= 1;
                        end
                    end 
                    
                    1:begin
                        tx <= 0;
                        sample_st <=2;
                    end

                    2:begin
                    while (tx_data) begin
                        tx <= tx_data[0];
                        tx_data <= tx_data >> 1;
                    end
                    sample_st <= 3;
                    end
                    3:begin
                        tx <= 1;
                        sample_st <=1;
                    end
                endcase
            end
        end
    end

    baud_rate_en baud_rate_en_inst(
        .rst(rst),
        .clk(clk),
        .rx_bd_en(bd8_rate),
        .tx_bd_en(bd_rate)
    );

    rx #(
        .PARITY("NONE")
    )
    rx_inst (
        .rst(rst),
        .clk(clk),
        .bd8_rate(bd8_rate),
        .rx_data(rx_data),
        .rx_rdy(rx_rdy),
        .rx(tx)
    );


endmodule