module baud_rate_en #(                          //波特率发生器程序
    parameter BAUD_RATE = 115200,
    parameter FREQUENCY = 100000000
) (
    input clk,rst,
    output reg tx_bd_en,rx_bd_en
);
localparam TX_DIV_COE = FREQUENCY / (BAUD_RATE) - 1;
localparam RX_DIV_COE = FREQUENCY / (BAUD_RATE*8) - 1;
reg [18:0] tx_clk_div,rx_clk_div ;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx_clk_div <= 0;
        rx_clk_div <= 0;
        tx_bd_en <= 0;
        rx_bd_en <= 0;
    end else begin
        tx_bd_en <=1'b0;
        if (tx_clk_div == TX_DIV_COE) begin
            tx_clk_div <= 0;
            tx_bd_en <= 1'b1;
        end else begin
            tx_clk_div <= tx_clk_div + 1;
        end
        rx_bd_en <= 1'b0;
        if (rx_clk_div == RX_DIV_COE) begin
            rx_clk_div <= 0;
            rx_bd_en <= 1'b1;
        end else begin
            rx_clk_div <= rx_clk_div + 1;
        end
    end
end
endmodule