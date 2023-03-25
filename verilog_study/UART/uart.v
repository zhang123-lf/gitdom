module uart #(
    parameter PARITY = "ODD"
) (
    input       inclk,

    input       tx_req,
    input [7:0] tx_data,
    output      tx_ack,

    output      tx,
    input       rx,

    input       rx_ack,
    output      rx_rdy,
    output      rx_data,
    input       rst
);
wire tx_bd_en,rx_bd_en;

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
        .clk(clk),
        .tx_bd_en(tx_bd_en),
        .tx_data(tx_data),
        .tx_rdy(tx_req),
        .tx_ack(tx_ack),
        .tx(tx)
    );
assign rx_rdy=0;
assign rx_data =0;
endmodule