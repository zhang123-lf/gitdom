module baud_rate_clk #(              //发送和接受波特率的时钟
    parameter BAUD_RATE=115200,     //波特率,每秒接受bit值
    parameter FREQUENCY=100000000      //时钟频率
) (
    input       clk,
    input       rst,
    output  reg tx_clk,
    output  reg rx_clk
);
    localparam TX_DIV_COE = FREQUENCY / (BAUD_RATE*2) - 1;   //2倍频过采样,这个是分频的需要计数到的值
    localparam RX_DIV_COE = FREQUENCY / (BAUD_RATE*8*2) - 1;   //八倍频过采样

    reg [18:0]  tx_clk_div ;        //定义分频所需要的寄存器
    reg [18:0]  rx_clk_div ;
    always @(posedge clk or posedge rst ) begin
        if (rst) begin
            tx_clk_div <= 0;
            rx_clk_div <= 0;
            tx_clk <= 0;
            rx_clk <= 0;
        end else begin
            if(tx_clk_div == TX_DIV_COE) begin
                tx_clk_div <= 0;
                tx_clk  <= ~tx_clk;
            end else begin
                tx_clk_div <= tx_clk_div + 1;
            end

            if (rx_clk_div == RX_DIV_COE) begin
                rx_clk_div <= 0;
                rx_clk = ~rx_clk;
            end else begin
                rx_clk_div <= rx_clk_div + 1;
            end
        end
    end
endmodule