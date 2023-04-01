module uart #(
    parameter PARITY = "ODD" //奇校验让他偶
) (
    input       inclk,

    input       tx_req,
    input [7:0] tx_data,
    output      tx_ack,

 //   output      tx,
  //  input       rx,

    input       rx_ack,
    output      rx_rdy,
    output [7:0]     rx_data,
    input       rst
);
wire tx_bd_en,rx_bd_en,data;

    baud_rate_en baud_rate_en_inst(
        .clk(inclk),
        .rst(rst),
        .tx_bd_en(tx_bd_en),
        .rx_bd_en(rx_bd_en)
    );
    tx #(
        .PARITY (PARITY),
        .STOP_BIT(1)
    ) 
    tx_inst(
        .rst(rst),
        .clk(inclk),
        .tx_bd_en(tx_bd_en),
        .tx_data(tx_data),
        .tx_rdy(tx_req),
        .tx_ack(tx_ack),
        .tx(data)
    );

    rx #(
        .PARITY(PARITY),
        .STOP_BIT(1)
    )
    rx_inst (
        .rst(rst),
        .clk(inclk),
        .bd8_rate(rx_bd_en),
        .rx_data(rx_data),
        .rx_rdy(rx_rdy),
        .rx(data)
    );
endmodule